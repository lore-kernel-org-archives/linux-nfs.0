Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175Ab2DQNgn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 09:36:43 -0400
Message-ID: <1334669800.5396.10.camel@localhost>
Subject: [PATCH 2/2] Avoid beyond bounds copy while caching ACL
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <trond.myklebust@netapp.com>,
        Andy Adamson <andros@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 17 Apr 2012 14:36:40 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When attempting to cache ACLs returned from the server, if the bitmap
size + the ACL size is greater than a PAGE_SIZE but the ACL size itself
is smaller than a PAGE_SIZE, we can read past the buffer page boundary.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
Reported-by: Jian Li <jiali@redhat.com>
---
 fs/nfs/nfs4proc.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bd54803..8f9d173 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3619,16 +3619,16 @@ out:
 	return ret;
 }
 
-static void nfs4_write_cached_acl(struct inode *inode, const char *buf, size_t acl_len)
+static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
 {
 	struct nfs4_cached_acl *acl;
 
-	if (buf && acl_len <= PAGE_SIZE) {
+	if (pages && acl_len <= PAGE_SIZE) {
 		acl = kmalloc(sizeof(*acl) + acl_len, GFP_KERNEL);
 		if (acl == NULL)
 			goto out;
 		acl->cached = 1;
-		memcpy(acl->data, buf, acl_len);
+		_copy_from_pages(acl->data, pages, pgbase, acl_len);
 	} else {
 		acl = kmalloc(sizeof(*acl), GFP_KERNEL);
 		if (acl == NULL)
@@ -3661,7 +3661,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	struct nfs_getaclres res = {
 		.acl_len = buflen,
 	};
-	void *resp_buf;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
 		.rpc_argp = &args,
@@ -3696,7 +3695,6 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	 * the page we send as a guess */
 	if (buf == NULL)
 		res.acl_flags |= NFS4_ACL_LEN_REQUEST;
-	resp_buf = page_address(pages[0]);
 
 	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
 		__func__, buf, buflen, npages, args.acl_len);
@@ -3707,9 +3705,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 
 	acl_len = res.acl_len - res.acl_data_offset;
 	if (acl_len > args.acl_len)
-		nfs4_write_cached_acl(inode, NULL, acl_len);
+		nfs4_write_cached_acl(inode, NULL, 0, acl_len);
 	else
-		nfs4_write_cached_acl(inode, resp_buf + res.acl_data_offset,
+		nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
 				      acl_len);
 	if (buf) {
 		ret = -ERANGE;
-- 
1.7.7.6



