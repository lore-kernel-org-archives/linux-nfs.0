From: andros@netapp.com
Subject: [PATCH 07/11] nfs41: fix switch in nfs4_recovery_handle_error
Date: Fri,  4 Dec 2009 15:25:42 -0500
Message-ID: <1259958347-9031-8-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
 <1259958347-9031-6-git-send-email-andros@netapp.com>
 <1259958347-9031-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757289AbZLDUZ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:57 -0500
In-Reply-To: <1259958347-9031-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not fall through and set NFS4CLNT_SESSION_RESET bit on NFS4ERR_EXPIRED

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4168fa6..91726bc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1078,6 +1078,7 @@ static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_EXPIRED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_start_reclaim_nograce(clp);
+			break;
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
 		case -NFS4ERR_BAD_HIGH_SLOT:
-- 
1.6.0.6

