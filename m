Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:55490 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaLXHON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:13 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so7202500iec.36
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:12 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 40/49] nfs: add nfs_pgio_current_mirror helper
Date: Tue, 23 Dec 2014 23:13:19 -0800
Message-Id: <1419405208-25975-41-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Let it return current nfs_pgio_mirror in use depending on pg_mirror_count.
For read, we always use pg_mirrors[0], so this effectively gives us freedom
to use pg_mirror_idx to track the actual mirror to read from through out the
IO stack.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/internal.h            |  2 ++
 fs/nfs/objlayout/objio_osd.c |  2 +-
 fs/nfs/pagelist.c            | 25 +++++++++++++++++--------
 fs/nfs/pnfs.c                |  9 ++++-----
 4 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5be06bc..ffe4b7a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -255,6 +255,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
 		      const struct rpc_call_ops *call_ops, int how, int flags);
 void nfs_free_request(struct nfs_page *req);
+struct nfs_pgio_mirror *
+nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9a5f2ee..24e1d74 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -537,7 +537,7 @@ int objio_write_pagelist(struct nfs_pgio_header *hdr, int how)
 static size_t objio_pg_test(struct nfs_pageio_descriptor *pgio,
 			  struct nfs_page *prev, struct nfs_page *req)
 {
-	struct nfs_pgio_mirror *mirror = &pgio->pg_mirrors[pgio->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(pgio);
 	unsigned int size;
 
 	size = pnfs_generic_pg_test(pgio, prev, req);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f9d8c46..960c99f 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -42,11 +42,20 @@ static bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
 	return p->pagevec != NULL;
 }
 
+struct nfs_pgio_mirror *
+nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc)
+{
+	return nfs_pgio_has_mirroring(desc) ?
+		&desc->pg_mirrors[desc->pg_mirror_idx] :
+		&desc->pg_mirrors[0];
+}
+EXPORT_SYMBOL_GPL(nfs_pgio_current_mirror);
+
 void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 		       struct nfs_pgio_header *hdr,
 		       void (*release)(struct nfs_pgio_header *hdr))
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 
 	hdr->req = nfs_list_entry(mirror->pg_list.next);
@@ -485,7 +494,7 @@ nfs_wait_on_request(struct nfs_page *req)
 size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *prev, struct nfs_page *req)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 
 	if (mirror->pg_count > mirror->pg_bsize) {
@@ -782,7 +791,7 @@ static void nfs_pgio_result(struct rpc_task *task, void *calldata)
 int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 		     struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	struct nfs_page		*req;
 	struct page		**pages,
@@ -831,7 +840,7 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 	struct nfs_pgio_header *hdr;
 	int ret;
 
-	mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	mirror = nfs_pgio_current_mirror(desc);
 
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
@@ -961,7 +970,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 				     struct nfs_page *req)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	struct nfs_page *prev = NULL;
 
@@ -985,7 +994,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
  */
 static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 
 	if (!list_empty(&mirror->pg_list)) {
@@ -1015,7 +1024,7 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *req)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	struct nfs_page *subreq;
 	unsigned int bytes_left = 0;
@@ -1078,7 +1087,7 @@ err_ptr:
 
 static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 	LIST_HEAD(head);
 
 	do {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e123cfc..b822b17 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1731,7 +1731,7 @@ static void
 pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		list_splice_tail_init(&hdr->pages, &mirror->pg_list);
@@ -1785,7 +1785,7 @@ EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	struct nfs_pgio_header *hdr;
 	int ret;
@@ -1846,8 +1846,7 @@ static void
 pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
-
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		list_splice_tail_init(&hdr->pages, &mirror->pg_list);
@@ -1903,7 +1902,7 @@ EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
 	struct nfs_pgio_header *hdr;
 	int ret;
-- 
1.9.3

