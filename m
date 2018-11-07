Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD99C0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:14:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2910B2086B
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:14:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2910B2086B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388931AbeKGNnF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:43:05 -0500
Received: from mx2.suse.de ([195.135.220.15]:56630 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388530AbeKGNnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:43:05 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E6261B6A2;
        Wed,  7 Nov 2018 04:14:27 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 09/23] NFSv4: add cl_root_cred for use when machine cred is
 not available.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395104.24086.17023670588890588198.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFSv4 state management tries a root credential when no machine
credential is available, as can happen with kerberos.
It does this by replacing the cl_machine_cred with a root credential.
This means that any user of the machine credential needs to take
a lock while getting a reference to the machine credential, which is
a little cumbersome.

So introduce an explicit cl_root_cred, and never free either
credential until client shutdown.  This means that no locking
is needed to reference these credentials.  Future patches
will make use of this.

This is only a temporary addition.  both cl_machine_cred and
cl_root_cred will disappear later in the series.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/client.c           |    2 ++
 fs/nfs/nfs4state.c        |   20 ++++++++++++--------
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 96d5f8135eb9..cce151776709 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -248,6 +248,8 @@ void nfs_free_client(struct nfs_client *clp)
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
+	if (clp->cl_root_cred != NULL)
+		put_rpccred(clp->cl_root_cred);
 
 	put_net(clp->cl_net);
 	put_nfs_version(clp->cl_nfs_mod);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 62ae0fd345ad..032d3ec929f3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -166,24 +166,28 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
-	struct rpc_cred *cred = NULL;
+	struct rpc_cred *cred = clp->cl_root_cred;
 
-	if (clp->cl_machine_cred != NULL)
-		cred = get_rpccred(clp->cl_machine_cred);
+	if (!cred)
+		cred = clp->cl_machine_cred;
+	if (cred)
+		return get_rpccred(cred);
 	return cred;
 }
 
 static void nfs4_root_machine_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *cred, *new;
+	struct rpc_cred *new;
 
 	new = rpc_lookup_machine_cred(NULL);
 	spin_lock(&clp->cl_lock);
-	cred = clp->cl_machine_cred;
-	clp->cl_machine_cred = new;
+	if (clp->cl_root_cred == NULL) {
+		clp->cl_root_cred = new;
+		new = NULL;
+	}
 	spin_unlock(&clp->cl_lock);
-	if (cred != NULL)
-		put_rpccred(cred);
+	if (new != NULL)
+		put_rpccred(new);
 }
 
 static struct rpc_cred *
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0fc0b9135d46..fea51b44fe50 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -59,6 +59,7 @@ struct nfs_client {
 
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
+	struct rpc_cred		*cl_root_cred;	/* Use when machine_cred is ineffective */
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 	struct list_head	cl_ds_clients; /* auth flavor data servers */


