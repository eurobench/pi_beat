#!/usr/bin/env python3

"""
@file test_docker_call.py
@author Anthony Remazeilles
@brief check the computation runs as expected

Copyright (C) 2020 Tecnalia Research and Innovation
Distributed under the Apache 2.0 (Apache 2.0).

"""

import os
import io
import unittest
import tempfile
import logging
import sys
import xml.dom.minidom

# Check https://stackoverflow.com/questions/32899/how-do-you-generate-dynamic-parameterized-unit-tests-in-python

class DockerCallTest(unittest.TestCase):
    """gather program tests
    """

    DOCKER_IMAGE = "pi_beat"

    def setUp(self):
        """Common initialization operations
        """

        self.log = logging.getLogger("test_log")

        self.log.debug("Setting up the test")

        self.log.debug("Testing image: {}".format(self.DOCKER_IMAGE))

        rel_path = os.path.dirname(__file__)
        test_folder = os.path.abspath(os.getcwd() + "/" + rel_path)
        ## Read the test plan
        plan_file = test_folder + "/test_plan.xml"
        self.log.debug("test plan file: {}".format(plan_file))

        plan_xml = xml.dom.minidom.parse(plan_file)
        all_test = plan_xml.getElementsByTagName("test")
        self.log.debug("number of tests: {}".format(all_test.length))

        test_detail = []

        for one_test in all_test:
            one_test_detail = {}
            one_test_detail['pi_name'] = one_test.getAttribute('pi_name')
            one_test_detail['parameters'] = one_test.getAttribute('parameters')
            one_test_detail['input_folder'] = one_test.getAttribute('input_folder')
            one_test_detail['output_folder'] = one_test.getAttribute('output_folder')

            # putting absolute path in path variables
            one_test_detail['input_folder'] = test_folder + '/' + one_test_detail['input_folder']
            one_test_detail['output_folder'] = test_folder + '/' + one_test_detail['output_folder']

            test_detail.append(one_test_detail)

        self.log.debug("Testing plan: {}".format(test_detail))

        self.test_detail = test_detail

    def test_call_docker(self):
        """test the docker component with stored input and output

        """

        for i, one_test in enumerate(self.test_detail):

            msg_test = "test {} on {}".format(i, one_test['pi_name'])
            with self.subTest(msg=msg_test):
                self.log.debug("Launching test {}".format(i))

                output_data_path = tempfile.mkdtemp()
                os.chmod(output_data_path, 0o777)

                # preparing the generation command
                self.command = "docker run --rm -v {}:/in -v {}:/out {} ".format(one_test['input_folder'],
                                                                                output_data_path,
                                                                                self.DOCKER_IMAGE)

                self.command += one_test['pi_name'] + ' ' + one_test['parameters']

                self.log.debug("Command generated: \n{}".format(self.command))

                self.log.info("Launching docker command")
                # TODO how to catch the result of the command (error or success)
                os.system(self.command)

                self.log.info("Docker command launched")

                # check generated files
                output_groundtruth_path = one_test['output_folder']

                output_files = os.listdir(output_data_path)
                output_files_expected = os.listdir(output_groundtruth_path)

                self.assertCountEqual(output_files, output_files_expected, msg="Missing generated files")

                # Check the content of each file

                for filename in output_files:
                    self.log.debug("comparing file: {}".format(filename))

                    file_generated = output_data_path + "/" + filename

                    lines_generated = list()
                    with open(file_generated) as f:
                        for line in f:
                            lines_generated.append(line)

                    file_groundtruth = output_groundtruth_path + "/" + filename

                    lines_groundtruth = list()
                    with open(file_groundtruth) as f:
                        for line in f:
                            lines_groundtruth.append(line)

                    # print("Comparing:\n{}\n with \n{}".format(lines_generated, lines_groundtruth))
                    self.assertListEqual(lines_generated, lines_groundtruth, msg="File {} differs".format(filename))

                    self.log.info("Test completed")
        self.log.info("All tests completed")


if __name__ == '__main__':
    print("test_docker_call -- testing image: {}".format(os.environ.get('DOCKER_IMAGE')))

    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

    DockerCallTest.DOCKER_IMAGE = os.environ.get('DOCKER_IMAGE', DockerCallTest.DOCKER_IMAGE)
    # TODO using https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # but it is mentioned as not preferrable.
    unittest.main()
