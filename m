Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43968 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932269AbeARTzD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jan 2018 14:55:03 -0500
Received: by mail-io0-f195.google.com with SMTP id 72so2478703iom.10
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jan 2018 11:55:03 -0800 (PST)
Subject: [PATCH] nfs: Use proper enum definitions for nfs_show_stable
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 18 Jan 2018 14:55:01 -0500
Message-ID: <20180118195500.10840.21322.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints") had a
hack to work around some odd behavior observed with
__print_symbolic. I couldn't ever get it to display NFS_FILE_SYNC
when using TRACE_DEFINE_ENUM macros to set up the enum values.

I tracked down the actual bug that forced me to add the workaround.
That issue will be addressed soon, so replace the hack with a proper
implementation.

Fixes: 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfstrace.h |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 093290c..c6dbd48 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -796,15 +796,15 @@
 		)
 );
 
-/*
- * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
- * all evaluate to 0 for some reason, even if I include linux/nfs.h.
- */
+TRACE_DEFINE_ENUM(NFS_UNSTABLE);
+TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
+TRACE_DEFINE_ENUM(NFS_FILE_SYNC);
+
 #define nfs_show_stable(stable) \
 	__print_symbolic(stable, \
-			{ 0, " (UNSTABLE)" }, \
-			{ 1, " (DATA_SYNC)" }, \
-			{ 2, " (FILE_SYNC)" })
+			{ NFS_UNSTABLE, "UNSTABLE" }, \
+			{ NFS_DATA_SYNC, "DATA_SYNC" }, \
+			{ NFS_FILE_SYNC, "FILE_SYNC" })
 
 TRACE_EVENT(nfs_initiate_write,
 		TP_PROTO(
@@ -837,12 +837,12 @@
 
 		TP_printk(
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"offset=%lld count=%lu stable=%d%s",
+			"offset=%lld count=%lu stable=%s",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
 			__entry->offset, __entry->count,
-			__entry->stable, nfs_show_stable(__entry->stable)
+			nfs_show_stable(__entry->stable)
 		)
 );
 
@@ -881,13 +881,13 @@
 
 		TP_printk(
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"offset=%lld status=%d stable=%d%s "
+			"offset=%lld status=%d stable=%s "
 			"verifier 0x%016llx",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
 			__entry->offset, __entry->status,
-			__entry->stable, nfs_show_stable(__entry->stable),
+			nfs_show_stable(__entry->stable),
 			__entry->verifier
 		)
 );

