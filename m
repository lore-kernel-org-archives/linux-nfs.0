Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0C99C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 13:36:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A4A0206BF
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 13:36:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725977AbfDYNgy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 09:36:54 -0400
Received: from mx1.redhat.com ([209.132.183.28]:39480 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725935AbfDYNgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 09:36:54 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 57414308A11E;
        Thu, 25 Apr 2019 13:36:54 +0000 (UTC)
Received: from idlethread.redhat.com (ovpn-116-36.ams2.redhat.com [10.36.116.36])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D9FC95D719;
        Thu, 25 Apr 2019 13:36:52 +0000 (UTC)
From:   Roberto Bergantinos Corpas <rbergant@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Subject: [PATCH] NFS: make nfs_match_client killable
Date:   Thu, 25 Apr 2019 15:36:51 +0200
Message-Id: <20190425133651.17618-1-rbergant@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 25 Apr 2019 13:36:54 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

    Actually we don't do anything with return value from
    nfs_wait_client_init_complete in nfs_match_client, as a
    consequence if we get a fatal signal and client is not
    fully initialised, we'll loop to "again" label

    This has been proven to cause soft lockups on some scenarios
    (no-carrier but configured network interfaces)

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 fs/nfs/client.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 90d71fda65ce..350cfa561e0e 100644
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
2.14.5

