Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51809 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab3FYShm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 14:37:42 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] NFSv4.1 Add the RPC header and other overhead to session parameters request
Date: Tue, 25 Jun 2013 14:37:32 -0400
Message-Id: <1372185454-1888-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

ca_maxresponsesize and ca_maxrequestsize include the RPC header. Add the
RPC header size and other xdr overhead in order to request NFS_MAX_FILE_IO_SIZE
of read and write data.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e40876..b569feb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6189,9 +6189,9 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		     mxresp_sz = session->fc_target_max_resp_sz;
 
 	if (mxrqst_sz == 0)
-		mxrqst_sz = NFS_MAX_FILE_IO_SIZE;
+		mxrqst_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxwrite_overhead;
 	if (mxresp_sz == 0)
-		mxresp_sz = NFS_MAX_FILE_IO_SIZE;
+		mxresp_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxread_overhead;
 	/* Fore channel attributes */
 	args->fc_attrs.max_rqst_sz = mxrqst_sz;
 	args->fc_attrs.max_resp_sz = mxresp_sz;
-- 
1.7.11.7

