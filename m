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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89B17C282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5636820811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cirC+Vpj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730680AbfDXVtE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:04 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:43483 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:04 -0400
Received: by mail-io1-f68.google.com with SMTP id v9so1390223iol.10
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1NpdRXbuR8e+I/hY3Bv0iQOCSMyOS0Ch4jG5GoOuBiQ=;
        b=cirC+Vpj8MLy2pwt/6RdS08L1I87bKJ5unWXMQ1Aw7Si7dwxlUUxO/zDsvC85XqWq1
         yt7yTovagm72mJ+Ztz8G5Jp3Zd3+1ZygRa/AGjOqtyJ7IqbhwiAWf8GvqgE3LW3h3mtd
         UQUjKiI2KmHEXJC+WUVhNz7mVCu3L8Ma7UhIz4OKOBQk+8LieXsBHz0K/HSBEhm7wfpq
         WImLpXoum3FRbPPGuGI3YxvXFHfE/xPPdzw0e/3D6ssClOQDIp3KmEUjm008vnEUdU4w
         ZjzOD9qnjNfS7d3jfFPdq4UWR3Xaiy/sLkSLflMZz2QBcoSIr77hT8l9mw4jGg8WSq1A
         +P5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=1NpdRXbuR8e+I/hY3Bv0iQOCSMyOS0Ch4jG5GoOuBiQ=;
        b=AIOdCNqyZdiYIcyH8Fr7GXfdmw5x70kLAl2mp4b8B3oiLp9wH/oFl4NOCJYpg+/Uja
         MD1XmHMlqU1eNmTINU0P3+UY9F/42vrgg8TAVeLcJt+6Yh1yvDS4zCKYYdZQsRTfa1GN
         6Ao8oWXFEGTG7hpVtiObnk57eC1TBT6H5ZTE/TNPqZCHy3BMsOGH00EgOvwGo8WJ6jFk
         Y/LWbO4LsqgkElDhBZf9YPpASelavn1vwUh1mwkCCIrg2p6VstXp96VgqtfwckE6gi26
         +wE7hy8erpWJ3iBn5cZg3aTMvEgw32p6SRFsAcdBdLd9lm+OvNDZ6eQM7KxVi+oozoXG
         eLyA==
X-Gm-Message-State: APjAAAWcJF858gz46+VMn9Gxj4Sk5ACCX6NQxR0uXOrG1a5u82WMRWzt
        JKx+ArsLcrUMzNHzklnJ5cB6jBc=
X-Google-Smtp-Source: APXvYqx8ydjL+r69IrRKFwuEoBHGtAOAAa10L77NA8g5kOkQRX1H2T8A5s9bwZQ/7uQrXi3TcAjLFg==
X-Received: by 2002:a6b:dc18:: with SMTP id s24mr20646448ioc.218.1556142543255;
        Wed, 24 Apr 2019 14:49:03 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:02 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/9] SUNRPC: Use the client user namespace when encoding creds
Date:   Wed, 24 Apr 2019 17:46:44 -0400
Message-Id: <20190424214650.4658-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-3-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When encoding AUTH_UNIX creds and AUTH_GSS upcalls, use the user namespace
of the process that created the rpc client.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 11 ++++++++---
 net/sunrpc/auth_unix.c         |  9 +++++----
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3fd56c0c90ae..e3601dc6c180 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -412,7 +412,10 @@ gss_upcall_callback(struct rpc_task *task)
 
 static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
 {
-	uid_t uid = from_kuid(&init_user_ns, gss_msg->uid);
+	struct user_namespace *userns = gss_msg->auth->client->cl_cred ?
+		gss_msg->auth->client->cl_cred->user_ns : &init_user_ns;
+
+	uid_t uid = from_kuid_munged(userns, gss_msg->uid);
 	memcpy(gss_msg->databuf, &uid, sizeof(uid));
 	gss_msg->msg.data = gss_msg->databuf;
 	gss_msg->msg.len = sizeof(uid);
@@ -424,13 +427,15 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 				const char *service_name,
 				const char *target_name)
 {
+	struct user_namespace *userns = gss_msg->auth->client->cl_cred ?
+		gss_msg->auth->client->cl_cred->user_ns : &init_user_ns;
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
 	size_t buflen = sizeof(gss_msg->databuf);
 	int len;
 
 	len = scnprintf(p, buflen, "mech=%s uid=%d", mech->gm_name,
-			from_kuid(&init_user_ns, gss_msg->uid));
+			from_kuid_munged(userns, gss_msg->uid));
 	buflen -= len;
 	p += len;
 	gss_msg->msg.len = len;
@@ -707,7 +712,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		goto err;
 	}
 
-	uid = make_kuid(&init_user_ns, id);
+	uid = make_kuid(current_user_ns(), id);
 	if (!uid_valid(uid)) {
 		err = -EINVAL;
 		goto err;
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index d4018e5a24c5..e7df1f782b2e 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -107,6 +107,8 @@ unx_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	__be32		*p, *cred_len, *gidarr_len;
 	int		i;
 	struct group_info *gi = cred->cr_cred->group_info;
+	struct user_namespace *userns = clnt->cl_cred ?
+		clnt->cl_cred->user_ns : &init_user_ns;
 
 	/* Credential */
 
@@ -122,14 +124,13 @@ unx_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	p = xdr_reserve_space(xdr, 3 * sizeof(*p));
 	if (!p)
 		goto marshal_failed;
-	*p++ = cpu_to_be32(from_kuid(&init_user_ns, cred->cr_cred->fsuid));
-	*p++ = cpu_to_be32(from_kgid(&init_user_ns, cred->cr_cred->fsgid));
+	*p++ = cpu_to_be32(from_kuid_munged(userns, cred->cr_cred->fsuid));
+	*p++ = cpu_to_be32(from_kgid_munged(userns, cred->cr_cred->fsgid));
 
 	gidarr_len = p++;
 	if (gi)
 		for (i = 0; i < UNX_NGROUPS && i < gi->ngroups; i++)
-			*p++ = cpu_to_be32(from_kgid(&init_user_ns,
-						     gi->gid[i]));
+			*p++ = cpu_to_be32(from_kgid_munged(userns, gi->gid[i]));
 	*gidarr_len = cpu_to_be32(p - gidarr_len - 1);
 	*cred_len = cpu_to_be32((p - cred_len - 1) << 2);
 	p = xdr_reserve_space(xdr, (p - gidarr_len - 1) << 2);
-- 
2.21.0

