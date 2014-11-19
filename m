Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:54372 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbaKSMvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:41 -0500
Received: by mail-qg0-f48.google.com with SMTP id q107so321691qgd.7
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:40 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] sunrpc: move rq_cachetype field to better optimize space
Date: Wed, 19 Nov 2014 07:51:19 -0500
Message-Id: <1416401482-2562-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are a couple of holes in the svc_rqst field on x86_64. Move the
rq_cachetype to a different location to eliminate both of them.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2714287fc4f6..8054a30c8a95 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -252,6 +252,7 @@ struct svc_rqst {
 	u32			rq_vers;	/* program version */
 	u32			rq_proc;	/* procedure number */
 	u32			rq_prot;	/* IP protocol */
+	int			rq_cachetype;	/* catering to nfsd */
 #define	RQ_SECURE	(0)			/* secure port */
 #define	RQ_LOCAL	(1)			/* local request */
 #define	RQ_USEDEFERRAL	(2)			/* use deferral */
@@ -278,7 +279,6 @@ struct svc_rqst {
 	/* Catering to nfsd */
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
-	int			rq_cachetype;
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 };
-- 
2.1.0

