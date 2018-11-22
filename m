Return-Path: <SRS0=4pmG=OB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8764EC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 20:00:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 421FE20892
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 20:00:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mjGOQjFw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 421FE20892
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2406907AbeKWGfT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Nov 2018 01:35:19 -0500
Received: from mail.kernel.org ([198.145.29.99]:34062 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2406918AbeKWGfT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Nov 2018 01:35:19 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id ECFF220645;
        Thu, 22 Nov 2018 19:54:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1542916467;
        bh=aTwI4/pfPbMTBfDQJjCinFDCd4jXV+d48YvFlJDMYP8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=mjGOQjFwfe4/FfHDX6DWobU2cQxOCiFWukVrjazb42TxEoMBM2j/KO6LF4XbNSJq0
         1jkWCbRmqMjv2VggS7+Nmk3yEGSW6RqtImCbT4NUIrLRUoLvNDkI2gEexkDFkAOvTg
         ooEnIbb8h145NwpR7aGB17thTu4ytfOiA1WDlgdM=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 30/36] NFSv4: Fix an Oops during delegation callbacks
Date:   Thu, 22 Nov 2018 14:52:34 -0500
Message-Id: <20181122195240.13123-30-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181122195240.13123-1-sashal@kernel.org>
References: <20181122195240.13123-1-sashal@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit e39d8a186ed002854196668cb7562ffdfbc6d379 ]

If the server sends a CB_GETATTR or a CB_RECALL while the filesystem is
being unmounted, then we can Oops when releasing the inode in
nfs4_callback_getattr() and nfs4_callback_recall().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/callback_proc.c |  4 ++--
 fs/nfs/delegation.c    | 11 +++++++++--
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5ea5ba..7b861bbc0b43 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -66,7 +66,7 @@ __be32 nfs4_callback_getattr(void *argp, void *resp,
 out_iput:
 	rcu_read_unlock();
 	trace_nfs4_cb_getattr(cps->clp, &args->fh, inode, -ntohl(res->status));
-	iput(inode);
+	nfs_iput_and_deactive(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
 	return res->status;
@@ -108,7 +108,7 @@ __be32 nfs4_callback_recall(void *argp, void *resp,
 	}
 	trace_nfs4_cb_recall(cps->clp, &args->fh, inode,
 			&args->stateid, -ntohl(res));
-	iput(inode);
+	nfs_iput_and_deactive(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index f033f3a69a3b..75fe92eaa681 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -849,16 +849,23 @@ nfs_delegation_find_inode_server(struct nfs_server *server,
 				 const struct nfs_fh *fhandle)
 {
 	struct nfs_delegation *delegation;
-	struct inode *res = NULL;
+	struct inode *freeme, *res = NULL;
 
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL &&
 		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
-			res = igrab(delegation->inode);
+			freeme = igrab(delegation->inode);
+			if (freeme && nfs_sb_active(freeme->i_sb))
+				res = freeme;
 			spin_unlock(&delegation->lock);
 			if (res != NULL)
 				return res;
+			if (freeme) {
+				rcu_read_unlock();
+				iput(freeme);
+				rcu_read_lock();
+			}
 			return ERR_PTR(-EAGAIN);
 		}
 		spin_unlock(&delegation->lock);
-- 
2.17.1

