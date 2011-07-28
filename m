Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59037 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/6] pynfs patches
Date: Thu, 28 Jul 2011 16:02:58 -0400
Message-Id: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This fixes a RECLAIM_COMPLETE bug that makes the tests work for me
again.

And also try sharing a few more things between 4.0 and 4.1.

The same patches are available from

	git://linux-nfs.org/~bfields/pynfs.git master

My biggest remaining annoyance is that the rename tests all go over the
nfs server's maximum op count.  pynfs should really be smart enough to
do the lookups in reasonable chunks.  Or we could probably find a
simpler workaround for the rename case.

(And I've also updated by test scripts to use the new merged project, at
git://linux-nfs.org/~bfields/testd.git.)

--b.

J. Bruce Fields (6):
  CLNT: provide new_client_session shortcut
  CLNT: send RECLAIM_COMPLETE when required
  Share showresults.py between 4.0 and 4.1
  Make top-level setup.py set up nfs4.0 as well
  Merge top-level READMEs
  Share testmod.py between nfs4.0 and nfs4.1

 README                              |   17 +-
 README-4.1                          |    8 -
 nfs4.0/lib/testmod.py               |  417 +----------------------------------
 nfs4.0/showresults.py               |   74 ------
 nfs4.1/nfs4client.py                |    6 +
 nfs4.1/server41tests/environment.py |    3 +-
 nfs4.1/server41tests/st_block.py    |   16 +-
 nfs4.1/server41tests/st_open.py     |   23 +--
 nfs4.1/server41tests/st_rename.py   |  108 +++------
 nfs4.1/server41tests/st_secinfo.py  |    6 +-
 nfs4.1/server41tests/st_sequence.py |    9 +-
 nfs4.1/showresults.py               |   74 ------
 setup.py                            |    6 +-
 showresults.py                      |   74 ++++++
 14 files changed, 158 insertions(+), 683 deletions(-)
 delete mode 100644 README-4.1
 mode change 100644 => 120000 nfs4.0/lib/testmod.py
 delete mode 100755 nfs4.0/showresults.py
 delete mode 100755 nfs4.1/showresults.py
 mode change 100644 => 100755 setup.py
 create mode 100755 showresults.py

-- 
1.7.4.1

