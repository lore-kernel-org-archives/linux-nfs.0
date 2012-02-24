Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45446 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab2BXFBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 00:01:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] 4.1 server tests: don't insist on 0-seqid trick in setup
Date: Fri, 24 Feb 2012 00:01:00 -0500
Message-Id: <1330059660-2053-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1330059660-2053-1-git-send-email-bfields@redhat.com>
References: <1330059660-2053-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The 4.1 spec requires servers to handle stateid's with seqid field 0
(they have the special meaning of "use the latest stateid in this
stateid stream").

We've seen buggy or incomplete servers that don't handle this yet.

We *should* add a test for that.  But insisting on it (for no real
reason) during setup just prevents all the other tests from running
unnecessarily.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/environment.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 2566274..24e82cd 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -190,7 +190,7 @@ class Environment(testmod.Environment):
                 log.warning("could not create /%s" % '/'.join(path))
         # Make file-object in /tree
         fh, stateid = create_confirm(sess, 'maketree', tree + ['file'])
-        stateid.seqid = 0
+        # stateid.seqid = 0
         ops = [op.putfh(fh),
                op.write(stateid, 0, FILE_SYNC4, self.filedata)]
         res = sess.compound(ops)
-- 
1.7.7.6

