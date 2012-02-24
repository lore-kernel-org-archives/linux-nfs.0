Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab2BXFBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 00:01:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] 4.1 server tests: add citation for COMP4b
Date: Fri, 24 Feb 2012 00:00:58 -0500
Message-Id: <1330059660-2053-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1330059660-2053-1-git-send-email-bfields@redhat.com>
References: <1330059660-2053-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/st_compound.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_compound.py b/nfs4.1/server41tests/st_compound.py
index d38f621..c6a5ea9 100644
--- a/nfs4.1/server41tests/st_compound.py
+++ b/nfs4.1/server41tests/st_compound.py
@@ -64,7 +64,7 @@ def testInvalidMinor(t, env):
 def testInvalidMinor2(t, env):
     """COMPOUND with invalid minor version returns NFS4ERR_MINOR_VERS_MISMATCH
 
-    even if using illegal opcode
+    even if using illegal opcode (rfc 5661 p. 399)
 
     FLAGS: compound all
     CODE: COMP4b
-- 
1.7.7.6

