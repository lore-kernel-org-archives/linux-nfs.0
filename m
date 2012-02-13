Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62957 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab2BMVvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:51:35 -0500
Received: by mail-ey0-f174.google.com with SMTP id h12so1933716eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:51:34 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bhalevy@tonian.com, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 06/10] nfsd41: save and restore current stateid with current fh
Date: Mon, 13 Feb 2012 22:54:40 +0100
Message-Id: <1329170084-7032-7-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
---
 fs/nfsd/nfs4proc.c |    2 ++
 fs/nfsd/xdr4.h     |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 66bd005..59d9b4b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -453,6 +453,7 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_restorefh;
 
 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
+	cstate->current_stateid = cstate->save_stateid;
 	return nfs_ok;
 }
 
@@ -464,6 +465,7 @@ nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_nofilehandle;
 
 	fh_dup2(&cstate->save_fh, &cstate->current_fh);
+	cstate->save_stateid = cstate->current_stateid;
 	return nfs_ok;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c1fe8ba..2ae378e 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -55,6 +55,7 @@ struct nfsd4_compound_state {
 	u32			minorversion;
 	u32			status;
 	const stateid_t	*current_stateid;
+	const stateid_t	*save_stateid;
 };
 
 static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
-- 
1.7.7.6

