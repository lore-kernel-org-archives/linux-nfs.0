Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48904 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab2GWKFZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jul 2012 06:05:25 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so7792703lbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jul 2012 03:05:24 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 3/3] pnfs: use size_t for LAYOUTGET response pages count
Date: Mon, 23 Jul 2012 13:05:07 +0300
Message-Id: <1343037907-26457-4-git-send-email-idank@tonian.com>
In-Reply-To: <1343037907-26457-1-git-send-email-idank@tonian.com>
References: <1343037907-26457-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Idan Kedar <idank@tonian.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/nfs4proc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3db9ce7..056c3f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6164,13 +6164,13 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	dprintk("<-- %s\n", __func__);
 }
 
-static u32 max_response_pages(struct nfs_server *server)
+static size_t max_response_pages(struct nfs_server *server)
 {
 	u32 max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
 	return nfs_page_array_len(0, max_resp_sz);
 }
 
-static void free_pagevec(struct page **pages, u32 size)
+static void free_pagevec(struct page **pages, size_t size)
 {
 	int i;
 
@@ -6185,7 +6185,7 @@ static void free_pagevec(struct page **pages, u32 size)
 	kfree(pages);
 }
 
-static struct page **alloc_pagevec(u32 size, gfp_t gfp_flags)
+static struct page **alloc_pagevec(size_t size, gfp_t gfp_flags)
 {
 	struct page **pages;
 	int i;
@@ -6212,7 +6212,7 @@ static void nfs4_layoutget_release(void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
-	u32 max_pages = max_response_pages(server);
+	size_t max_pages = max_response_pages(server);
 
 	dprintk("--> %s\n", __func__);
 	free_pagevec(lgp->args.layout.pages, max_pages);
@@ -6230,7 +6230,7 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
-	u32 max_pages = max_response_pages(server);
+	size_t max_pages = max_response_pages(server);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
-- 
1.7.6.5

