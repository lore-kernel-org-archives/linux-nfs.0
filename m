Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A758C282C2
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:37:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5ADEC20811
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:37:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IpRaQ6wX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730999AbfBFQhH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 11:37:07 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:51461 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730520AbfBFQhH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 11:37:07 -0500
Received: by mail-it1-f196.google.com with SMTP id w18so7639639ite.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2019 08:37:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=gmKL/OgdCW2sD5QIwElSDtSu3SIMZSA6alITvbznIPs=;
        b=IpRaQ6wXyqWwTQ7ER+MtgUf6KJFls5KhRpsO+VHI0wOW+cLJRU/P8P5BpKqOAU8KN/
         kfoQIYcHiHiIZ4LLkjCiPczQEEQbOduGbhjBhIgxHYSGjXfUKdWWoDZXJsh2RNyodV7j
         EFW7U1vif1X1LdfeS1CAWMiXVeQZPJhTyL1maYd8FRIZSi2JQ1soJEhqjHcbgtBRvK+0
         9zPFwZV9DnkJqeBX+QoUPGe71TurSsh9SftOd5wRwP1AuoA55nEwbBYqHNv63Qj7ejxu
         M/eErQQ3Zg4r4k7mV8j0DiS1jCAZJlL5SSPwcHrxXATJOlGfM+0hBKMo4JB/2VhL5x/s
         DE9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=gmKL/OgdCW2sD5QIwElSDtSu3SIMZSA6alITvbznIPs=;
        b=Savp/Oi+7lGYI6VuoD4vDX0iD2fT1qwm6Hg/Us7r4uolgQzmzNzoP+bLvpgvXnupjt
         JAWKFvLsp9SEa5Hc+kOyYtXdVG+h/L/vPHcZOMQ+qZYNxhaFXwQAqTLyyiryaYPgcrqB
         us3w+GXf66Snc59pw09mvZW/59JmUn9rAVjUAfUUAVLimTwDU8LsXomE9U+eetYN68ZU
         KaPmManNNXCF2HpN7EhVcM6PnIzYCGiS0WzrcMhkL6MrkBj8jqXZiaHhjxVFhB/PsDvs
         UMNNuntbOYTxmlG4NDEJvNMdgbbioqxd49oSup9OURwszVa69trv/qi+xuO3EBZTzmMm
         Ey2Q==
X-Gm-Message-State: AHQUAuZGjfTmYvJTNhlkOnKNtC/se3FIF8dv+ASr6OCUWuT/vf4ZqmIa
        95KU91O1MDOwaII5h46TYNRqSTyL
X-Google-Smtp-Source: AHgI3IbI3+P5zRaSupilZJfpdDVfTPjkHrUr0wVBypFoegnuttyvHqBVzkpJnsND4xP6da5aw6fjNA==
X-Received: by 2002:a6b:7602:: with SMTP id g2mr5680059iom.135.1549471026209;
        Wed, 06 Feb 2019 08:37:06 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y38sm4091998ita.18.2019.02.06.08.37.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:37:05 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16Gb4PX015993
        for <linux-nfs@vger.kernel.org>; Wed, 6 Feb 2019 16:37:04 GMT
Subject: [PATCH RFC 3/5] SUNRPC: Make AUTH_SYS and AUTH_NULL set au_verfsize
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 11:37:04 -0500
Message-ID: <20190206163704.16810.51008.stgit@manet.1015granger.net>
In-Reply-To: <20190206163256.16810.62516.stgit@manet.1015granger.net>
References: <20190206163256.16810.62516.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

au_verfsize will be needed for a non-flavor-specific computation
in a subsequent patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/auth.h    |    3 +--
 net/sunrpc/auth_gss/auth_gss.c |    1 +
 net/sunrpc/auth_null.c         |    1 +
 net/sunrpc/auth_unix.c         |    5 ++++-
 4 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index c51e189..359dfdd 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -77,8 +77,7 @@ struct rpc_auth {
 				/* guess at number of u32's auth adds before
 				 * reply data; normally the verifier size: */
 	unsigned int		au_rslack;
-				/* for gss, used to calculate au_rslack: */
-	unsigned int		au_verfsize;
+	unsigned int		au_verfsize;	/* size of reply verifier */
 
 	unsigned int		au_flags;	/* various flags */
 	const struct rpc_authops *au_ops;		/* operations */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index fda454c..731e7a4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1016,6 +1016,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 	auth = &gss_auth->rpc_auth;
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
+	auth->au_verfsize = GSS_VERF_SLACK >> 2;
 	auth->au_flags = 0;
 	auth->au_ops = &authgss_ops;
 	auth->au_flavor = flavor;
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index bf96975..9ae0824 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -114,6 +114,7 @@
 struct rpc_auth null_auth = {
 	.au_cslack	= NUL_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
+	.au_verfsize	= NUL_REPLYSLACK,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
 	.au_count	= REFCOUNT_INIT(1),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 5ea84a9..a93c564 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -163,6 +163,7 @@
 static int
 unx_validate(struct rpc_task *task, struct xdr_stream *xdr)
 {
+	struct rpc_auth *auth = task->tk_rqstp->rq_cred->cr_auth;
 	__be32 *p;
 	u32 size;
 
@@ -184,7 +185,8 @@
 	if (!p)
 		return -EIO;
 
-	task->tk_rqstp->rq_cred->cr_auth->au_rslack = (size >> 2) + 2;
+	auth->au_verfsize = XDR_QUADLEN(size) + 2;
+	auth->au_rslack = XDR_QUADLEN(size) + 2;
 	return 0;
 }
 
@@ -212,6 +214,7 @@ void rpc_destroy_authunix(void)
 struct rpc_auth		unix_auth = {
 	.au_cslack	= UNX_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
+	.au_verfsize	= NUL_REPLYSLACK,
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= REFCOUNT_INIT(1),

