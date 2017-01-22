Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:33940 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAVTEc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2017 14:04:32 -0500
Received: by mail-it0-f45.google.com with SMTP id k200so19807745itb.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Jan 2017 11:04:31 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:1dce])
        by smtp.gmail.com with ESMTPSA id k6sm8280272ioe.1.2017.01.22.11.04.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 11:04:30 -0800 (PST)
Subject: [PATCH v1] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 22 Jan 2017 14:04:29 -0500
Message-ID: <20170122190429.7337.77928.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Xuan Qi reports that the Linux NFSv4 client failed to lock a file
that was migrated. The steps he observed on the wire:

1. The client sent a LOCK request
2. The server replied NFS4ERR_MOVED
3. The client switched to the destination server
4. The client sent the LOCK request again with a bumped
   lock sequence ID
5. The server rejected the LOCK request with NFS4ERR_BAD_SEQID

RFC 3530 section 8.1.5 provides a list of NFS errors which do not
bump a lock sequence ID.

However, RFC 3530 is now obsoleted by RFC 7530. In RFC 7530 section
9.1.7, this list has been updated by the addition of NFS4ERR_MOVED.

Reported-by: Xuan Qi <xuan.qi@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # v3.7+
---
 include/linux/nfs4.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

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

