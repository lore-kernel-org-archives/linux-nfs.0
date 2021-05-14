Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A40CAC433ED
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:56:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7ADC861492
	for <linux-nfs@archiver.kernel.org>; Fri, 14 May 2021 19:56:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232816AbhENT5N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 May 2021 15:57:13 -0400
Received: from mail.kernel.org ([198.145.29.99]:57138 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232807AbhENT5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 May 2021 15:57:13 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 6F34361554;
        Fri, 14 May 2021 19:56:01 +0000 (UTC)
Subject: [PATCH v3 08/24] NFSD: Add nfsd_clid_destroyed tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     dwysocha@redhat.com, bfields@fieldses.org
Date:   Fri, 14 May 2021 15:56:00 -0400
Message-ID: <162102216069.10915.4192160459284653788.stgit@klimt.1015granger.net>
In-Reply-To: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
References: <162102191240.10915.5003178983503027218.stgit@klimt.1015granger.net>
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
index 03f2770c815f..08ff643e96fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3907,6 +3907,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
 		status = nfserr_wrong_cred;
 		goto out;
 	}
+	trace_nfsd_clid_destroyed(&clp->cl_clientid);
 	unhash_client_locked(clp);
 out:
 	spin_unlock(&nn->client_lock);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 18be3fbb96ea..d6ba6a1a1e63 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -513,6 +513,7 @@ DEFINE_EVENT(nfsd_clientid_class, nfsd_clid_##name, \
 
 DEFINE_CLIENTID_EVENT(reclaim_complete);
 DEFINE_CLIENTID_EVENT(confirmed);
+DEFINE_CLIENTID_EVENT(destroyed);
 DEFINE_CLIENTID_EVENT(expired);
 DEFINE_CLIENTID_EVENT(purged);
 DEFINE_CLIENTID_EVENT(renew);


