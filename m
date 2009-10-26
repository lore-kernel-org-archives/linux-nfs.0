Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbZJZMwl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2009 08:52:41 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9QCqkFs016251
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2009 08:52:46 -0400
Received: from localhost.localdomain (vpn-10-19.rdu.redhat.com [10.11.10.19])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9QCqj0S021864
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2009 08:52:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfs-utils: add testing infrastructure to nfs-utils
Date: Mon, 26 Oct 2009 08:52:43 -0400
Message-Id: <1256561565-5909-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patchset is intended as a starting point for an automated test
suite for nfs-utils. The idea here is to start simply and add a suite of
tests that we can run via "make check" -- the standard automake method
for running tests.

Clearly there are limits to what we can test with out a multi-host test
harness, but my hope is that this should keep us from breaking basic
functionality by allowing us to test it in a very simple fashion. At
some point in the future we should also consider how to best handle
multi-machine testing, but I see that as complimenting this code rather
than replacing it.

For this set, the focus is on testing statd, which is particularly
susceptible to subtle breakage. Problems with it are often not noticed
until lock recovery breaks, and that may greatly lag the actual
breakage.

To faciitate statd testing, I've added a "statdtest" program that can
serve as a synthetic statd client and an NLM simulator. It's very
loosely based on the old statd simulator code. That program is dependent
on some of Chuck's recent statd patches -- notably the ones that break
out common NSM code into libnsm.a.

For this initial drop, I'm just adding a single test that tests
mon and unmon functionality with statd. Adding more tests shouldn't be
too hard, however.

At this point, I'm mostly interested in general feedback on the concept.
Does this seem like a reasonable starting point for automated nfs-utils

Jeff Layton (2):
  nfs-utils: introduce new statd testing simulator
  nfs-utils: add initial tests for statd that run via "make check"

 Makefile.am                          |    2 +-
 configure.ac                         |    4 +-
 tests/Makefile.am                    |    7 +
 tests/statdtest/Makefile.am          |   45 ++++
 tests/statdtest/README               |   12 +
 tests/statdtest/nlm_sm_inter.x       |   43 ++++
 tests/statdtest/statdtest.c          |  462 ++++++++++++++++++++++++++++++++++
 tests/t0001-statd-basic-mon-unmon.sh |   56 ++++
 tests/test-lib.sh                    |   41 +++
 9 files changed, 670 insertions(+), 2 deletions(-)
 create mode 100644 tests/Makefile.am
 create mode 100644 tests/statdtest/Makefile.am
 create mode 100644 tests/statdtest/README
 create mode 100644 tests/statdtest/nlm_sm_inter.x
 create mode 100644 tests/statdtest/statdtest.c
 create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
 create mode 100755 tests/test-lib.sh

