Return-Path: <SRS0=9PwK=TW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F83EC282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 22 May 2019 19:59:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2548C20862
	for <linux-nfs@archiver.kernel.org>; Wed, 22 May 2019 19:59:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558555165;
	bh=0UCL52sMqSGxS7cfWNuiFXECeJ8AXVSDRIFJhr4+Kj8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=YNFD9OhDi6F76I8aIsqflFrN6DxANPwWwxMiesOO6Gj8zHCXAC8sfHJKmWT9N028D
	 nKsT5yjso4Cs1bl6pF9D4JNsE3jPZW2a/fmsNWS5jLDjh4DYf3AhKNxbjoK5iA0kbA
	 wUcKSnWTr+duNKnj4JdH9vXr1Ej8UMe9hCfEggtA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730558AbfEVT7S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 May 2019 15:59:18 -0400
Received: from mail.kernel.org ([198.145.29.99]:44660 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730963AbfEVTXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 May 2019 15:23:44 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8E83821473;
        Wed, 22 May 2019 19:23:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1558553023;
        bh=0UCL52sMqSGxS7cfWNuiFXECeJ8AXVSDRIFJhr4+Kj8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=jd9TmS56NbfzR57Jpkp+jTssCHeMAD8Gr+3Ave524h4LlOwAddmcwe/eapVAA7i1t
         ivoDGVIHAG4wox+x8vdwiwmQS9aUsjpopNTTyMZSsWX2HyDkpS+QYHq6cGPUTtAz/m
         6QngxelyOAn2DqyzatXqERsVmkyIAwJE9vJuPc1w=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Roberto Bergantinos Corpas <rbergant@redhat.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.0 004/317] NFS: make nfs_match_client killable
Date:   Wed, 22 May 2019 15:18:25 -0400
Message-Id: <20190522192338.23715-4-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190522192338.23715-1-sashal@kernel.org>
References: <20190522192338.23715-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Roberto Bergantinos Corpas <rbergant@redhat.com>

[ Upstream commit 950a578c6128c2886e295b9c7ecb0b6b22fcc92b ]

    Actually we don't do anything with return value from
    nfs_wait_client_init_complete in nfs_match_client, as a
    consequence if we get a fatal signal and client is not
    fully initialised, we'll loop to "again" label

    This has been proven to cause soft lockups on some scenarios
    (no-carrier but configured network interfaces)

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/client.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 90d71fda65cec..350cfa561e0e8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -284,6 +284,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 	struct nfs_client *clp;
 	const struct sockaddr *sap = data->addr;
 	struct nfs_net *nn = net_generic(data->net, nfs_net_id);
+	int error;
 
 again:
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
@@ -296,8 +297,10 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (clp->cl_cons_state > NFS_CS_READY) {
 			refcount_inc(&clp->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
-			nfs_wait_client_init_complete(clp);
+			error = nfs_wait_client_init_complete(clp);
 			nfs_put_client(clp);
+			if (error < 0)
+				return ERR_PTR(error);
 			spin_lock(&nn->nfs_client_lock);
 			goto again;
 		}
@@ -407,6 +410,8 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 		clp = nfs_match_client(cl_init);
 		if (clp) {
 			spin_unlock(&nn->nfs_client_lock);
+			if (IS_ERR(clp))
+				return clp;
 			if (new)
 				new->rpc_ops->free_client(new);
 			return nfs_found_client(cl_init, clp);
-- 
2.20.1

