From: andros@netapp.com
Subject: [PATCH 06/11] nfs41: fix switch in nfs4_handle_exception
Date: Fri,  4 Dec 2009 15:25:41 -0500
Message-ID: <1259958347-9031-7-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
 <1259958347-9031-5-git-send-email-andros@netapp.com>
 <1259958347-9031-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757288AbZLDUZ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:56 -0500
In-Reply-To: <1259958347-9031-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not fall through and call nfs4_delay on session error handling.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee4a987..8b8bd31 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -272,7 +272,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 				errorcode);
 			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 			exception->retry = 1;
-			/* FALLTHROUGH */
+			break;
 #endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 		case -NFS4ERR_GRACE:
-- 
1.6.0.6

