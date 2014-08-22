Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:63719 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaHVTLJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 15:11:09 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so6965117iec.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 12:11:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] nfsd: Mark back channel down if SESSION4_BACK_CHAN is
	clear
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 22 Aug 2014 15:11:07 -0400
Message-ID: <20140822191107.3883.84107.stgit@klimt.1015granger.net>
In-Reply-To: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a client indicates via CREATE_SESSION that no back channel
should be used on the existing connection, mark the client's
cl_cb_state DOWN instead of leaving it UNKNOWN.

Otherwise, a fresh session is created without an operational
backchannel, but the server never asserts SEQ4_STATUS_CB_PATH_DOWN.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4state.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a45f244..d7cfd8b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1429,6 +1429,9 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
 
+	if (!(cses->flags & SESSION4_BACK_CHAN))
+		clp->cl_cb_state = NFSD4_CB_DOWN;
+
 	{
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*

