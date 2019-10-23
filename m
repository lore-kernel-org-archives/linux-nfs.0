Return-Path: <SRS0=iyIL=YQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4649ACA9EB9
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 17516207FD
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O7j6RCVE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392808AbfJWX6O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Oct 2019 19:58:14 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:44608 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725852AbfJWX6O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Oct 2019 19:58:14 -0400
Received: by mail-io1-f66.google.com with SMTP id w12so27189907iol.11
        for <linux-nfs@vger.kernel.org>; Wed, 23 Oct 2019 16:58:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qubh+bjzZm2oRJ17euw6moPDnTcR50x5U/G07rZbOqo=;
        b=O7j6RCVEWiVX5K8REElseAOmx6JaFro0G19e/klH1BQQEhDkz7DPcndD7GdT2V2rfJ
         v6WGyKPRnvpy9zN+uCUuzrjI1Z6bEIwQQVGt4xfn/Ez/y8Dnz5NP4i4tPzsAccOHsEl+
         t1KW2Uh2VH2/pijbPt/h+C1gH4ugAmME/yZfd5bZxYL3ZZNbuyS09pXpwih4eHTrE2ht
         CnMlApBCuoJa+7tMA4tfur0ghcsZ/0HvdBEkKk+TLHelbjErYB9LQH1MsQr4iooWMaP6
         5a1IdgnGQrf28mH6crwYV0weyCL1YeS+BHKDA9QFlJ54abAxTdYxJH7PMj0qiSIBkod6
         hrLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=qubh+bjzZm2oRJ17euw6moPDnTcR50x5U/G07rZbOqo=;
        b=dPE8JoOs6LK+B0JJZUue5Ysp+lMg6TEr1rOuoeOTkgysS6vDA5OVqJnxAeyg6KM61C
         l7HTYim+wBiNeUdbxJce58w1PAt2ZiAYIfel5hjceYKsAbt/yBjwQXeo7A5bkH57axj8
         D8z/erWVVwRa88S9m/CiARHFbI3bRtDSVNog62leCObWeYPTzZc+IyYo4Ya1IwsgiCeC
         gtO/sx4OIEMSqtbWpChEN15AJglPddfAXUW2a2KjNS4GdMRuRJFiRB2L41DNBsK702Oi
         t95mhBLyDvQ8yVlsv3XphTW6HIsAM/Ytmj0oIPRv/geVOYNLmmma35CBv/c+osoNteUq
         tosg==
X-Gm-Message-State: APjAAAUqN/c9kPpGlXCzGuCsAwW+TrfHxL+YLFLmtOQfPBQmQumVI7Ev
        zpxZ6QWYSOnFqeDjLXtgnncGLRo=
X-Google-Smtp-Source: APXvYqxlH+eHcaec5sdghlqns3z95I8e2+cp3dIUe6ByhHaxB05x1oOSeqcAeHFAqI3+X9Oizm02nQ==
X-Received: by 2002:a6b:4405:: with SMTP id r5mr6315346ioa.177.1571875092591;
        Wed, 23 Oct 2019 16:58:12 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id z18sm2405409iob.47.2019.10.23.16.58.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Oct 2019 16:58:12 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 04/14] NFSv4: Delegation recalls should not find revoked delegations
Date:   Wed, 23 Oct 2019 19:55:50 -0400
Message-Id: <20191023235600.10880-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20191023235600.10880-4-trond.myklebust@hammerspace.com>
References: <20191023235600.10880-1-trond.myklebust@hammerspace.com>
 <20191023235600.10880-2-trond.myklebust@hammerspace.com>
 <20191023235600.10880-3-trond.myklebust@hammerspace.com>
 <20191023235600.10880-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If we're processsing a delegation recall, ignore the delegations that
have already been revoked or returned.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5f3eea926af5..4bc40c27141b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -830,7 +830,7 @@ int nfs_async_inode_return_delegation(struct inode *inode,
 
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation == NULL)
+	if (!nfs4_is_valid_delegation(delegation, FMODE_READ))
 		goto out_enoent;
 	if (stateid != NULL &&
 	    !clp->cl_mvops->match_stateid(&delegation->stateid, stateid))
@@ -855,6 +855,7 @@ nfs_delegation_find_inode_server(struct nfs_server *server,
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL &&
+		    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) &&
 		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
 			freeme = igrab(delegation->inode);
 			if (freeme && nfs_sb_active(freeme->i_sb))
-- 
2.21.0

