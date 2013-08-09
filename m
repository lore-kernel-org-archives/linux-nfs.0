Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f48.google.com ([209.85.213.48]:53441 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:52:41 -0400
Received: by mail-yh0-f48.google.com with SMTP id b20so1515402yha.7
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:52:41 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id u25sm20682948yhl.23.2013.08.09.09.52.39
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:52:40 -0700 (PDT)
Subject: [PATCH v2 32/33] NFS: Implement NFSv4.1 support for
 NFS4ERR_LEASE_MOVED
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:52:38 -0400
Message-ID: <20130809165238.5362.6039.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 minor version 0 servers return an error code,
NFS4ERR_LEASE_MOVED, to signal LEASE_MOVED.  This error causes the
whole compound to fail.

Minor version 1+ servers set a bit flag in the reply to a compound's
SEQUENCE operation to signal LEASE_MOVED.  The compound succeeds.

After the server sets one of the sr_status_flags in a typical
compound operation, nfs41_sequence_done() initiates standard lease
recovery.  A stand-alone SEQUENCE operation is performed to
discover what recovery is needed.

If the LEASE_MOVED status flag is set in this SEQUENCE operation,
our client kick offs LEASE_MOVED recovery.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 175c0c7..5510ab2 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2204,9 +2204,10 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs41_handle_server_reboot(clp);
 	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
 			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
-			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
-			    SEQ4_STATUS_LEASE_MOVED))
+			    SEQ4_STATUS_ADMIN_STATE_REVOKED))
 		nfs41_handle_state_revoked(clp);
+	if (flags & SEQ4_STATUS_LEASE_MOVED)
+		nfs4_schedule_lease_moved_recovery(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
 	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)

