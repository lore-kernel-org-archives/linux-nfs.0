Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] 4.0 server tests: remove RD12 (incorrect test)
Date: Wed, 15 Feb 2012 17:45:20 -0500
Message-Id: <1329345920-16608-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

>From 3530 section 8.1.4:

	In the case of WRITE-type operations (i.e., WRITEs and SETATTRs
	which set size), the server must verify that the access mode
	allows writing and return an NFS4ERR_OPENMODE error if it does
	not.  In the case, of READ, the server may perform the
	corresponding check on the access mode, or it may choose to
	allow READ on opens for WRITE only, to accommodate clients whose
	write implementation may unavoidably do reads (e.g., due to
	buffer cache constraints).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.0/servertests/st_read.py |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/nfs4.0/servertests/st_read.py b/nfs4.0/servertests/st_read.py
index 639b436..cce9a03 100644
--- a/nfs4.0/servertests/st_read.py
+++ b/nfs4.0/servertests/st_read.py
@@ -219,17 +219,3 @@ def testOldStateid(t, env):
     fh, stateid = c.confirm(t.code, res)
     res = c.read_file(fh, stateid=oldstateid)
     check(res, NFS4ERR_OLD_STATEID, "READ with old stateid")
-
-def testOpenMode(t, env):
-    """READ with file opened in WRITE mode should return NFS4_OK or NFS4ERR_OPENMODE
-
-    FLAGS: read all
-    DEPEND: MKFILE
-    CODE: RD12
-    """
-    c = env.c1
-    c.init_connection()
-    fh, stateid = c.create_confirm(t.code, access=OPEN4_SHARE_ACCESS_WRITE)
-    res = c.read_file(fh, stateid=stateid)
-    check(res, NFS4ERR_OPENMODE, "READ with file opened in WRITE mode",
-          [NFS4_OK])
-- 
1.7.5.4

