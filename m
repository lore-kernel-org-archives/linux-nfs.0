Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FEFDC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EB851207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qJKESO/9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726582AbfDBXqW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:22 -0400
Received: from mail-pl1-f194.google.com ([209.85.214.194]:32772 "EHLO
        mail-pl1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXqW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:22 -0400
Received: by mail-pl1-f194.google.com with SMTP id t16so5170207plo.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=n7erfCjlP/3or6EgiH+wakce9kz8CJXGcwa4+Dblv3A=;
        b=qJKESO/9a2iHd5w8Ixdy0xnC5DsDNLydMJsPWx/BABevWND/5cAucFYGbA6HPzs1jF
         8l9VDd6PbIGVGkLrdISQbsWRKMqIK1/yT4oox4nWIA+A+gafj2tPZtsber4+nhm80S0j
         ckKSROxpcqUfc17iC6y7ZmcRfq5QsMBfusjqM9aOaoHO8y3SNPGeuk8OKwkg5Bal3Qvb
         HtjG5F6eqHaANyt4H/Ii6bUKQiHItYafdzipwsOWkabncr8ueSCXHd82E7cFuvGq7O6B
         DO4aYlz1eLsCtZ7tKt8NwvGIoimT5elidp2EebwG88xSAdMUFk5vG9a83hPoO74+xLLh
         pS6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=n7erfCjlP/3or6EgiH+wakce9kz8CJXGcwa4+Dblv3A=;
        b=CWo5UwSn5rzYnwHROLtzpPK62Qhm9Zix4t03Q26s01P2+qWQS7Z0FiYNhRxPqYUtwU
         B5rm/GUlOuO8UbzWMLrXztJA6liSeo3m37gUF1WUV2h9qIGgcpx9LAmRibWXRpOlDd7z
         c51h0eRUU3ZltD9gXdtpNuOeBNbX1yIEgLbjVwe5SiHOLWjrWRZ5cThhDBqCk7KUWjR3
         B/jTiTIE4I88E+YKDrvjzAHKOJI+lQb5ehcDpidjJZxtgMu3EUvo9qSSQHvBMhsFGf2x
         G6YLksYTOAYfRRM3B6WcRnamWLAcVx5U0oMqF7wwos/IhKhdIfLNsTTu7LHFXhIRdkRk
         0V3A==
X-Gm-Message-State: APjAAAVwyNlpJP4S1VnyRcOQFQrK2LU2BgS1s+mMugvl0m1DI6IumNl7
        6UX4LvbiHXGis5X6Y5FU8Gz8TSg=
X-Google-Smtp-Source: APXvYqxE3jt8wp5vB7WyhOIFlLAkGyGPnF3pSq4ETMPuC3AJqDFcWORoIjoPs9lACRu1FOY6Opawog==
X-Received: by 2002:a17:902:28a7:: with SMTP id f36mr73684145plb.169.1554248781291;
        Tue, 02 Apr 2019 16:46:21 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:20 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] SUNRPC: Fix the server AUTH_UNIX userspace mappings
Date:   Tue,  2 Apr 2019 16:44:09 -0700
Message-Id: <20190402234411.28204-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402234411.28204-3-trond.myklebust@hammerspace.com>
References: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
 <20190402234411.28204-2-trond.myklebust@hammerspace.com>
 <20190402234411.28204-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

gid_parse() is part of a downcall, so uids and gids should be assumed
encoded using the current user namespace.
svcauth_unix_accept() is, on the other hand, decoding uids and gids from
the wire, so we assume those are encoded to match the user namespace of
the server process.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svcauth_unix.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index fb9041b92f72..f92ef79c8ea5 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -500,7 +500,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 	rv = get_int(&mesg, &id);
 	if (rv)
 		return -EINVAL;
-	uid = make_kuid(&init_user_ns, id);
+	uid = make_kuid(current_user_ns(), id);
 	ug.uid = uid;
 
 	expiry = get_expiry(&mesg);
@@ -522,7 +522,7 @@ static int unix_gid_parse(struct cache_detail *cd,
 		err = -EINVAL;
 		if (rv)
 			goto out;
-		kgid = make_kgid(&init_user_ns, gid);
+		kgid = make_kgid(current_user_ns(), gid);
 		if (!gid_valid(kgid))
 			goto out;
 		ug.gi->gid[i] = kgid;
@@ -555,7 +555,7 @@ static int unix_gid_show(struct seq_file *m,
 			 struct cache_detail *cd,
 			 struct cache_head *h)
 {
-	struct user_namespace *user_ns = &init_user_ns;
+	struct user_namespace *user_ns = m->file->f_cred->user_ns;
 	struct unix_gid *ug;
 	int i;
 	int glen;
@@ -796,6 +796,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
+	struct user_namespace *userns;
 	u32		slen, i;
 	int		len   = argv->iov_len;
 
@@ -816,8 +817,10 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	 * (export-specific) anonymous id by nfsd_setuser.
 	 * Supplementary gid's will be left alone.
 	 */
-	cred->cr_uid = make_kuid(&init_user_ns, svc_getnl(argv)); /* uid */
-	cred->cr_gid = make_kgid(&init_user_ns, svc_getnl(argv)); /* gid */
+	userns = (rqstp->rq_xprt && rqstp->rq_xprt->xpt_cred) ?
+		rqstp->rq_xprt->xpt_cred->user_ns : &init_user_ns;
+	cred->cr_uid = make_kuid(userns, svc_getnl(argv)); /* uid */
+	cred->cr_gid = make_kgid(userns, svc_getnl(argv)); /* gid */
 	slen = svc_getnl(argv);			/* gids length */
 	if (slen > UNX_NGROUPS || (len -= (slen + 2)*4) < 0)
 		goto badcred;
@@ -825,7 +828,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	if (cred->cr_group_info == NULL)
 		return SVC_CLOSE;
 	for (i = 0; i < slen; i++) {
-		kgid_t kgid = make_kgid(&init_user_ns, svc_getnl(argv));
+		kgid_t kgid = make_kgid(userns, svc_getnl(argv));
 		cred->cr_group_info->gid[i] = kgid;
 	}
 	groups_sort(cred->cr_group_info);
-- 
2.20.1

