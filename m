Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716Ab0AFMxg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 07:53:36 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] nfs-utils: add testing infrastructure to nfs-utils (try #4)
Date: Wed,  6 Jan 2010 07:53:28 -0500
Message-Id: <1262782412-7050-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is an updated patchset for adding test infrastructure to nfs-utils.
The main differences in this patchset are:

1) turned the routine to convert a private cookie to a hex string into
a libnsm.a routine.

2) made statdb_dump print out more fields. It now dumps out pretty
much everything.

3) have test-lib.sh set $srcdir if it isn't set and sanity check its
value. That should allow running tests outside of the automake test
harness.

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
 support/nsm/file.c                   |   42 +++-
 tests/Makefile.am                    |   13 +
 tests/nsm_client/Makefile.am         |   45 ++++
 tests/nsm_client/README              |   12 +
 tests/nsm_client/nlm_sm_inter.x      |   43 +++
 tests/nsm_client/nsm_client.c        |  465 ++++++++++++++++++++++++++++++++++
 tests/statdb_dump.c                  |   98 +++++++
 tests/t0001-statd-basic-mon-unmon.sh |   55 ++++
 tests/test-lib.sh                    |   48 ++++
 12 files changed, 818 insertions(+), 11 deletions(-)
 create mode 100644 tests/Makefile.am
 create mode 100644 tests/nsm_client/Makefile.am
 create mode 100644 tests/nsm_client/README
 create mode 100644 tests/nsm_client/nlm_sm_inter.x
 create mode 100644 tests/nsm_client/nsm_client.c
 create mode 100644 tests/statdb_dump.c
 create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
 create mode 100755 tests/test-lib.sh

