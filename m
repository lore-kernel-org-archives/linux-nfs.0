Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34965 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754082AbdAZSBe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 13:01:34 -0500
Received: by mail-io0-f194.google.com with SMTP id m98so5698366iod.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 10:00:19 -0800 (PST)
Subject: [PATCH v2] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 26 Jan 2017 13:00:17 -0500
Message-ID: <20170126175938.6021.69650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Xuan Qi reports that the Linux NFSv4 client failed to lock a file
that was migrated. The steps he observed on the wire:

1. The client sent a LOCK request to the source server
2. The source server replied NFS4ERR_MOVED
3. The client switched to the destination server
4. The client sent the LOCK request to the destination
   server with a bumped lock sequence ID
5. The destination server rejected the LOCK request with
   NFS4ERR_BAD_SEQID

RFC 3530 section 8.1.5 provides a list of NFS errors which do not
bump a lock sequence ID.

However, RFC 3530 is now obsoleted by RFC 7530. In RFC 7530 section
9.1.7, this list has been updated by the addition of NFS4ERR_MOVED.

Reported-by: Xuan Qi <xuan.qi@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Xuan Qi <xuan.qi@oracle.com>
Cc: stable@vger.kernel.org # v3.7+
---
Testing confirms this patch addresses the problem that Xuan first
observed.


 fs/nfs/nfs4state.c   |    1 +
 include/linux/nfs4.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 90e6193..daeb94e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1091,6 +1091,7 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 		case -NFS4ERR_BADXDR:
 		case -NFS4ERR_RESOURCE:
 		case -NFS4ERR_NOFILEHANDLE:
+		case -NFS4ERR_MOVED:
 			/* Non-seqid mutating errors */
 			return;
 	};
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index bca5363..1b1ca04 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -282,7 +282,7 @@ enum nfsstat4 {
 
 static inline bool seqid_mutating_err(u32 err)
 {
-	/* rfc 3530 section 8.1.5: */
+	/* See RFC 7530, section 9.1.7 */
 	switch (err) {
 	case NFS4ERR_STALE_CLIENTID:
 	case NFS4ERR_STALE_STATEID:
@@ -291,6 +291,7 @@ static inline bool seqid_mutating_err(u32 err)
 	case NFS4ERR_BADXDR:
 	case NFS4ERR_RESOURCE:
 	case NFS4ERR_NOFILEHANDLE:
+	case NFS4ERR_MOVED:
 		return false;
 	};
 	return true;

