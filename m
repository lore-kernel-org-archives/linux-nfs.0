Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758Ab0AFPUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 10:20:33 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH 0/4] nfs-utils: add testing infrastructure to nfs-utils (try #5)
Date: Wed,  6 Jan 2010 10:20:05 -0500
Message-Id: <1262791209-8045-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is an updated patchset for adding test infrastructure to nfs-utils.
The main differences in this patchset are mostly small cleanups and
changes response to comments from Chuck Lever.

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

To faciitate statd testing, I've added a "nsm_client" program that can
serve as a synthetic statd client and an NLM simulator. It's very
loosely based on the old statd simulator code. That program is dependent
on some of Chuck Lever's recent statd patches -- notably the ones that
break out common NSM code into libnsm.a.

For this initial drop, I'm just adding a single test that tests mon and
unmon functionality with statd. Adding more tests should be fairly simple
to do.

Jeff Layton (4):
  nfs-utils: make private cookie to hex conversion a library routine
  nfs-utils: introduce new statd testing simulator
  nfs-utils: add statdb_dump utility
  nfs-utils: add initial tests for statd that run via "make check"

 Makefile.am                          |    2 +-
 configure.ac                         |    4 +-
 support/include/nsm.h                |    2 +
 support/nsm/file.c                   |   44 +++-
 tests/Makefile.am                    |   13 +
 tests/nsm_client/Makefile.am         |   45 ++++
 tests/nsm_client/README              |   12 +
 tests/nsm_client/nlm_sm_inter.x      |   43 +++
 tests/nsm_client/nsm_client.c        |  465 ++++++++++++++++++++++++++++++++++
 tests/statdb_dump.c                  |   99 +++++++
 tests/t0001-statd-basic-mon-unmon.sh |   55 ++++
 tests/test-lib.sh                    |   48 ++++
 12 files changed, 820 insertions(+), 12 deletions(-)
 create mode 100644 tests/Makefile.am
 create mode 100644 tests/nsm_client/Makefile.am
 create mode 100644 tests/nsm_client/README
 create mode 100644 tests/nsm_client/nlm_sm_inter.x
 create mode 100644 tests/nsm_client/nsm_client.c
 create mode 100644 tests/statdb_dump.c
 create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
 create mode 100755 tests/test-lib.sh

