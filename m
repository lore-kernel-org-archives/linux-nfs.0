Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE3A2C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 815FC21473
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ITVwMtSd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726530AbfDIQPz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:15:55 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:55663 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726515AbfDIQPz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 12:15:55 -0400
Received: by mail-it1-f195.google.com with SMTP id y134so5834957itc.5
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 09:15:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=n7erfCjlP/3or6EgiH+wakce9kz8CJXGcwa4+Dblv3A=;
        b=ITVwMtSdkU+0ppz9zqFMuvjwDHLE39mEWzexOVlR8yQa+06Zdgf2mTU9x7d8zcooJT
         g1ZEiE2ltM+FMJGroP2Z7X3NJeVQgbkZblCIK/hhoXCMo07MpdVQcNWlOAorRBhP285u
         MMXaSOaRiwx05Dw17+Cfl/Zhmv+oFzNLsizUPRaFRFdx5Df3mobXjAf2SHHca233FPOF
         VieKVuld58GIBdVfmhBb9ssDDHvbYhU66VL/9fSbEGluHe0uZ5wJ3j3MxAhw/3w2/Z68
         WsHhLCQCZBHCiRBcaZF3sBe/eiOtnSZcG9Q66lwS5Z8wSZ+iQd8y6Z+mzmdTJyqyRj4B
         VpJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=n7erfCjlP/3or6EgiH+wakce9kz8CJXGcwa4+Dblv3A=;
        b=uXZERaRQ7/Y9A7hqSVNRt1S5V91WnY9KQ+QHen5wXk/DDhHS1YjpkPLLz0Km+sXG1e
         XO1/mHjScmHhh0dubGGL7Py7U4pFjACEJS8sdDCYf6aZyY/1aFVYkTaqfhLThxtnSyWb
         aEBD2PNqJE4TGp6bOBC6lyKezzwACYcnWvU5UOAON+YMibPOPgBW4aoJHlj4KV9QwXWI
         eTSPvGmv0v4rVYbrGLkGUpToBtx619imhn6DL0Wt3Mdb8t9Vq0Ac2o3gB0a39bD3cOMf
         RKtaUSf92PUhXp4DkKd1EtGsKslhLIOkTE6oBogCEciHJxw6eWep0iavJigEWEQH69RV
         /aPQ==
X-Gm-Message-State: APjAAAVwtsFOvXWIlRoNjksd3/U6BZ/xC02eTFsdHdU53x1MBGKOdpiE
        sSDwCa0d7KHU9qhIYgvn6MODjLk=
X-Google-Smtp-Source: APXvYqzsRT9Ouomx7KxuMVH54F/dPkYGzUnejBOY7RHwTwQsVVeFoFLiIr6xcFWB1BVbkew88LWMNg==
X-Received: by 2002:a24:4149:: with SMTP id x70mr25886323ita.145.1554826554537;
        Tue, 09 Apr 2019 09:15:54 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d133sm7402425ita.5.2019.04.09.09.15.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 09:15:53 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] SUNRPC: Fix the server AUTH_UNIX userspace mappings
Date:   Tue,  9 Apr 2019 12:13:40 -0400
Message-Id: <20190409161342.34338-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409161342.34338-4-trond.myklebust@hammerspace.com>
References: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
 <20190409161342.34338-2-trond.myklebust@hammerspace.com>
 <20190409161342.34338-3-trond.myklebust@hammerspace.com>
 <20190409161342.34338-4-trond.myklebust@hammerspace.com>
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

