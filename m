Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	UPPERCASE_50_75,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9821DC43460
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 641C461139
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239513AbhDNNof (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Apr 2021 09:44:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:52144 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1351585AbhDNNoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Apr 2021 09:44:17 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id DEF93611B0
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2021 13:43:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1618407836;
        bh=V5X6yA3MN6KRnuZ82v7bhzecoijFgN0fpVDH5KVCCl0=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=NokslGvpox4MNFQjgtnTuKQT2xXOVfsWnOc8kj1jVV08yIWbcED05RNtSicbyYDCZ
         l4L1c9q9/rkjFXs4Q6IoFoTg36mb5k8YDwOpBCLT+1uRmkzWDdkhIq+/ChIFgj5IcX
         gOuOaeb1OAb2rqUgFF4OKQqyt+O4Jw0teumE0yA8gcsOG42MLyLPJl2U2rSsvJzC/5
         x5WLEri9nM3Ci3Uhn4asmUsl6hnIMXDjKDglSSFUcjei4iBlNz9Qtk45Etox3zz7TR
         iwc0j854iEKMtb1A5UTwqV11IXK4pBW1811Fv1KiBBi7hRpxoRPdkxNssV4vV4hIr/
         7HCVBMk4a/l4g==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/26] NFS: Fix up inode cache tracing
Date:   Wed, 14 Apr 2021 09:43:29 -0400
Message-Id: <20210414134353.11860-3-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210414134353.11860-2-trondmy@kernel.org>
References: <20210414134353.11860-1-trondmy@kernel.org>
 <20210414134353.11860-2-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Add missing enum definitions and missing entries for
nfs_show_cache_validity().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfstrace.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 5a59dcdce0b2..cdba6eebe3cb 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -45,6 +45,9 @@ TRACE_DEFINE_ENUM(NFS_INO_INVALID_CTIME);
 TRACE_DEFINE_ENUM(NFS_INO_INVALID_MTIME);
 TRACE_DEFINE_ENUM(NFS_INO_INVALID_SIZE);
 TRACE_DEFINE_ENUM(NFS_INO_INVALID_OTHER);
+TRACE_DEFINE_ENUM(NFS_INO_DATA_INVAL_DEFER);
+TRACE_DEFINE_ENUM(NFS_INO_INVALID_BLOCKS);
+TRACE_DEFINE_ENUM(NFS_INO_INVALID_XATTR);
 
 #define nfs_show_cache_validity(v) \
 	__print_flags(v, "|", \
@@ -60,6 +63,8 @@ TRACE_DEFINE_ENUM(NFS_INO_INVALID_OTHER);
 			{ NFS_INO_INVALID_MTIME, "INVALID_MTIME" }, \
 			{ NFS_INO_INVALID_SIZE, "INVALID_SIZE" }, \
 			{ NFS_INO_INVALID_OTHER, "INVALID_OTHER" }, \
+			{ NFS_INO_DATA_INVAL_DEFER, "DATA_INVAL_DEFER" }, \
+			{ NFS_INO_INVALID_BLOCKS, "INVALID_BLOCKS" }, \
 			{ NFS_INO_INVALID_XATTR, "INVALID_XATTR" })
 
 TRACE_DEFINE_ENUM(NFS_INO_ADVISE_RDPLUS);
-- 
2.30.2

