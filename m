Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46942 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaHVTLB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 15:11:01 -0400
Received: by mail-ie0-f177.google.com with SMTP id at20so6977519iec.22
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 12:11:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFSD: Always initialize cl_cb_addr
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 22 Aug 2014 15:10:59 -0400
Message-ID: <20140822191059.3883.7753.stgit@klimt.1015granger.net>
In-Reply-To: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A client may not want to use the back channel on a transport it sent
CREATE_SESSION on, in which case it clears SESSION4_BACK_CHAN.

However, cl_cb_addr should be populated anyway, to be used if the
client binds other connections to this session. If cl_cb_addr is
not initialized, rpc_create() fails when the server attempts to
set up a back channel on such secondary transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e80a59..a45f244 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1429,7 +1429,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
 
-	if (cses->flags & SESSION4_BACK_CHAN) {
+	{
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*
 		 * This is a little silly; with sessions there's no real

