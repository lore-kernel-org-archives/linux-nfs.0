Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E509C433B4
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 15:53:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E94826161C
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 15:53:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231805AbhEJPyh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 May 2021 11:54:37 -0400
Received: from mail.kernel.org ([198.145.29.99]:44474 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231753AbhEJPyf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 May 2021 11:54:35 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 5262D6161E;
        Mon, 10 May 2021 15:53:29 +0000 (UTC)
Subject: [PATCH RFC 18/21] NFSD: Add nfsd_clid_destroyed tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
To:     dwysocha@redhat.com, bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 10 May 2021 11:53:28 -0400
Message-ID: <162066200859.94415.14040468789531492561.stgit@klimt.1015granger.net>
In-Reply-To: <162066179690.94415.203187037032448300.stgit@klimt.1015granger.net>
References: <162066179690.94415.203187037032448300.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Record client-requested termination of client IDs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c |    1 +
 fs/nfsd/trace.h     |    1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f40d948964f5..52e03e9ab021 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3909,6 +3909,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
 		status = nfserr_wrong_cred;
 		goto out;
 	}
+	trace_nfsd_clid_destroyed(&clp->cl_clientid);
 	unhash_client_locked(clp);
 out:
 	spin_unlock(&nn->client_lock);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index a39a7c9ac217..9567840f8580 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -511,6 +511,7 @@ DEFINE_EVENT(nfsd_clientid_class, nfsd_clid_##name, \
 	TP_ARGS(clid))
 
 DEFINE_CLIENTID_EVENT(confirmed);
+DEFINE_CLIENTID_EVENT(destroyed);
 DEFINE_CLIENTID_EVENT(expired);
 DEFINE_CLIENTID_EVENT(purged);
 DEFINE_CLIENTID_EVENT(renew);


