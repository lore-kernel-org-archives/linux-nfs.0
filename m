Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33557 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616AbbFPOtA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:49:00 -0400
Received: by padev16 with SMTP id ev16so14234302pad.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:49:00 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 04/11] pNFS/flexfiles: Remove unused struct members user_name, group_name
Date: Tue, 16 Jun 2015 22:47:25 +0800
Message-Id: <1434466052-10491-5-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 070f204..275e4b7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -48,8 +48,6 @@ struct nfs4_ff_layout_mirror {
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
 	nfs4_stateid			stateid;
-	struct nfs4_string		user_name;
-	struct nfs4_string		group_name;
 	u32				uid;
 	u32				gid;
 	struct rpc_cred			*cred;
-- 
1.8.3.1

