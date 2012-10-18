Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:52822 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756361Ab2JROoW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Oct 2012 10:44:22 -0400
Received: by mail-qa0-f53.google.com with SMTP id s11so1315577qaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 07:44:21 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 18 Oct 2012 22:44:21 +0800
Message-ID: <CAPgLHd_u-xX9oHdst_nCf0h+HmSigU7euOy3UYbemc=Um7trSw@mail.gmail.com>
Subject: [PATCH] nfsd4: remove unused variable in nfsd4_delegreturn()
From: Wei Yongjun <weiyj.lk@gmail.com>
To: bfields@fieldses.org
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The variable inode is initialized but never used
otherwise, so remove the unused variable.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d0237f8..620ff81 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3807,12 +3807,10 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_delegation *dp;
 	stateid_t *stateid = &dr->dr_stateid;
 	struct nfs4_stid *s;
-	struct inode *inode;
 	__be32 status;
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
-	inode = cstate->current_fh.fh_dentry->d_inode;
 
 	nfs4_lock_state();
 	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s, cstate->minorversion);

