Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964944AbZLPTkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2009 14:40:42 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBGJeflG005692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2009 14:40:42 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfs-utils: add testing infrastructure to nfs-utils
Date: Wed, 16 Dec 2009 14:40:38 -0500
Message-Id: <1260992440-8234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This set is the same as the one I sent a month or so ago, with some
small changes to account for header file changes in Chuck's tree. This
patchset depends on the patches that add libnsm.a to nfs-utils.

This patchset is intended as a starting point for an automated test
suite for nfs-utils. The idea here is to start simply and add a suite of
tests that we can run via "make check" -- the standard automake method
for running tests.

Clearly there are limits to what we can test without a multi-host test
harness. My hope is that this should help keep us from breaking basic
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
on some of Chuck Lever's recent statd patches -- notably the ones that
break out common NSM code into libnsm.a.

For this initial drop, I'm just adding a single test that tests mon and
unmon functionality with statd. Adding more tests should fairly simple
to do.

Jeff Layton (2):
  nfs-utils: introduce new statd testing simulator
  nfs-utils: add initial tests for statd that run via "make check"

 Makefile.am                          |    2 +-
 configure.ac                         |    4 +-
 tests/Makefile.am                    |    7 +
 tests/statdtest/Makefile.am          |   45 ++++
 tests/statdtest/README               |   12 +
 tests/statdtest/nlm_sm_inter.x       |   43 +++
 tests/statdtest/statdtest.c          |  464 ++++++++++++++++++++++++++++++++++
 tests/t0001-statd-basic-mon-unmon.sh |   55 ++++
 tests/test-lib.sh                    |   41 +++
 9 files changed, 671 insertions(+), 2 deletions(-)
 create mode 100644 tests/Makefile.am
 create mode 100644 tests/statdtest/Makefile.am
 create mode 100644 tests/statdtest/README
 create mode 100644 tests/statdtest/nlm_sm_inter.x
 create mode 100644 tests/statdtest/statdtest.c
 create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
 create mode 100755 tests/test-lib.sh

