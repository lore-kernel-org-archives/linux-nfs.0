Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8489C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A971720811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SS27dTz6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730692AbfDXVtG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:06 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:38790 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:05 -0400
Received: by mail-io1-f66.google.com with SMTP id y6so9538992ior.5
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ckmjwr79ZbA8bZ5ZYgaJdznfIUUXyGwh9E9ib/i0+uU=;
        b=SS27dTz6p5NCuS1MgdE+53asmddb+mZgCwv3D5y++dN2/9lt3p1d9Berk/QOSc5AhL
         Bx5jJOxUJ94chC0TkwSCgxi8+SLtOzxvQOvTRO2MXpyw1LYlopP53rAMLZ0jzDiyviXk
         Dpv8B954YLrXSMd0uKdXTPPBR0Qi6BFxdCCaHn5xWJQn+fgsO1FEWVsNQXGceuf9jPqH
         qbbVaPFvd7ItZ5L5+V/JiCRnZ+2BFA8preR3oA0NXkiwWrVJsSl//sOMCfn5JubgGbow
         vLEDk+B2bGM7i3TWqWdXIpqLF0OLYGNk25HcyIftZR0UIWQRYBS8oPW0IAZGV9AETBBF
         KqHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ckmjwr79ZbA8bZ5ZYgaJdznfIUUXyGwh9E9ib/i0+uU=;
        b=mbFro2qL3mCI1q3hXVzahFc9cJPnM8DdbY+BXHlMgNMWgweuQbVUS6XYArzfeeE4uw
         uXUClDOUmV4HcLVZMuZQZqCDtjTGlHe2cXkILKVQWty4Hha3B/3YEiCAP4oArgC3DsWy
         k9IatCZFAyf0Bmj6pNKhu9jHkMUXomigjDpjnGnJ/Pj02EJ3XeArtn+qYgd5H4hfztaM
         ubeYT5Vn31ZDGbku6Q/B6nKhhTEI/iLvD/BdAamkfAcsxuQFmRkSPXNUodRXMnxlGo5T
         V/G+C/wbxPGZ0ZqIzWhQ/WqXufOCAcaRONfySLVtg15AhFi9Lq6rFGrB2DU4VY++cmm2
         zbaw==
X-Gm-Message-State: APjAAAW6u5GfWrod3rdZKF6cXDcKKoLe4csyrWw2e9nkfs8PmmbOX52f
        Z1ns85uop2bP5/lP6sfEgG2+feY=
X-Google-Smtp-Source: APXvYqxcsQ7vq4P8KLmHD/KTzH/9CpcXgWWEuNKL+k98SaBcQY4vMF1pM7FCrk+DxyW38U5busbM0Q==
X-Received: by 2002:a6b:7804:: with SMTP id j4mr1697861iom.171.1556142544435;
        Wed, 24 Apr 2019 14:49:04 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:03 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] SUNRPC: Use namespace of listening daemon in the client AUTH_GSS upcall
Date:   Wed, 24 Apr 2019 17:46:45 -0400
Message-Id: <20190424214650.4658-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-4-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the client needs to talk to rpc.gssd, we should ensure that the
uid argument is encoded to match the user namespace of the daemon.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 60 +++++++++++++++++++++++++---------
 1 file changed, 44 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e3601dc6c180..6baa8fd77c29 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -269,6 +269,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 struct gss_upcall_msg {
 	refcount_t count;
 	kuid_t	uid;
+	const char *service_name;
 	struct rpc_pipe_msg msg;
 	struct list_head list;
 	struct gss_auth *auth;
@@ -316,6 +317,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 		gss_put_ctx(gss_msg->ctx);
 	rpc_destroy_wait_queue(&gss_msg->rpc_waitqueue);
 	gss_put_auth(gss_msg->auth);
+	kfree_const(gss_msg->service_name);
 	kfree(gss_msg);
 }
 
@@ -410,10 +412,10 @@ gss_upcall_callback(struct rpc_task *task)
 	gss_release_msg(gss_msg);
 }
 
-static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
+static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg,
+			      const struct cred *cred)
 {
-	struct user_namespace *userns = gss_msg->auth->client->cl_cred ?
-		gss_msg->auth->client->cl_cred->user_ns : &init_user_ns;
+	struct user_namespace *userns = cred->user_ns;
 
 	uid_t uid = from_kuid_munged(userns, gss_msg->uid);
 	memcpy(gss_msg->databuf, &uid, sizeof(uid));
@@ -423,12 +425,24 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 	BUILD_BUG_ON(sizeof(uid) > sizeof(gss_msg->databuf));
 }
 
+static ssize_t
+gss_v0_upcall(struct file *file, struct rpc_pipe_msg *msg,
+		char __user *buf, size_t buflen)
+{
+	struct gss_upcall_msg *gss_msg = container_of(msg,
+						      struct gss_upcall_msg,
+						      msg);
+	if (msg->copied == 0)
+		gss_encode_v0_msg(gss_msg, file->f_cred);
+	return rpc_pipe_generic_upcall(file, msg, buf, buflen);
+}
+
 static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				const char *service_name,
-				const char *target_name)
+				const char *target_name,
+				const struct cred *cred)
 {
-	struct user_namespace *userns = gss_msg->auth->client->cl_cred ?
-		gss_msg->auth->client->cl_cred->user_ns : &init_user_ns;
+	struct user_namespace *userns = cred->user_ns;
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
 	size_t buflen = sizeof(gss_msg->databuf);
@@ -496,6 +510,25 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	return -ENOMEM;
 }
 
+static ssize_t
+gss_v1_upcall(struct file *file, struct rpc_pipe_msg *msg,
+		char __user *buf, size_t buflen)
+{
+	struct gss_upcall_msg *gss_msg = container_of(msg,
+						      struct gss_upcall_msg,
+						      msg);
+	int err;
+	if (msg->copied == 0) {
+		err = gss_encode_v1_msg(gss_msg,
+					gss_msg->service_name,
+					gss_msg->auth->target_name,
+					file->f_cred);
+		if (err)
+			return err;
+	}
+	return rpc_pipe_generic_upcall(file, msg, buf, buflen);
+}
+
 static struct gss_upcall_msg *
 gss_alloc_msg(struct gss_auth *gss_auth,
 		kuid_t uid, const char *service_name)
@@ -518,16 +551,11 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 	refcount_set(&gss_msg->count, 1);
 	gss_msg->uid = uid;
 	gss_msg->auth = gss_auth;
-	switch (vers) {
-	case 0:
-		gss_encode_v0_msg(gss_msg);
-		break;
-	default:
-		err = gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
-		if (err)
+	if (service_name) {
+		gss_msg->service_name = kstrdup_const(service_name, GFP_NOFS);
+		if (!gss_msg->service_name)
 			goto err_put_pipe_version;
 	}
-	kref_get(&gss_auth->kref);
 	return gss_msg;
 err_put_pipe_version:
 	put_pipe_version(gss_auth->net);
@@ -2121,7 +2149,7 @@ static const struct rpc_credops gss_nullops = {
 };
 
 static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
-	.upcall		= rpc_pipe_generic_upcall,
+	.upcall		= gss_v0_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
 	.open_pipe	= gss_pipe_open_v0,
@@ -2129,7 +2157,7 @@ static const struct rpc_pipe_ops gss_upcall_ops_v0 = {
 };
 
 static const struct rpc_pipe_ops gss_upcall_ops_v1 = {
-	.upcall		= rpc_pipe_generic_upcall,
+	.upcall		= gss_v1_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
 	.open_pipe	= gss_pipe_open_v1,
-- 
2.21.0

