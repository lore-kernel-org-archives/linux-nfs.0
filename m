Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:38339 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606Ab2FDVBz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2012 17:01:55 -0400
Received: by gglu4 with SMTP id u4so3437733ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2012 14:01:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] rpcdebug: Add new "state" flag for the nfs module
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 04 Jun 2012 17:01:53 -0400
Message-ID: <20120604210153.13269.10747.stgit@oracle-2.citi.umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kernel 3.5 adds a debugging flag for showing NFS client debugging
messages having to do with NFSv4 state operations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfs/debug.h |    1 +
 tools/rpcdebug/rpcdebug.c   |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/support/include/nfs/debug.h b/support/include/nfs/debug.h
index dbec5ba..80a1b1d 100644
--- a/support/include/nfs/debug.h
+++ b/support/include/nfs/debug.h
@@ -79,6 +79,7 @@ enum {
 #define NFSDBG_FSCACHE		0x0800
 #define NFSDBG_PNFS			0x1000
 #define NFSDBG_PNFS_LD		0x2000
+#define NFSDBG_STATE		0x4000
 #define NFSDBG_ALL		0xFFFF
 
 #endif /* _NFS_DEBUG_H */
diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index 444616d..d6e10d3 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -170,6 +170,7 @@ static struct flagmap {
 	FLAG(NFS,       FSCACHE),
 	FLAG(NFS,       PNFS),
 	FLAG(NFS,       PNFS_LD),
+	FLAG(NFS,	STATE),
 	FLAG(NFS,	ALL),
 
 	/* nfsd */

