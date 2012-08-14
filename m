Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab2HNWru (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 18:47:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Dros Adamson <Weston.Adamson@netapp.com>
Cc: Sachin Prabhu <sprabhu@redhat.com>,
        Andy Adamson <William.Adamson@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Fix the acl cache size calculation
Date: Tue, 14 Aug 2012 18:47:26 -0400
Message-Id: <1344984447-17804-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1344984447-17804-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1344984447-17804-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we do not take into account the size of the 16 byte
struct nfs4_cached_acl header, when deciding whether or not we should
cache the acl data.  Consequently, we will end up allocating an
8k buffer in order to fit a maximum size 4k acl.

This patch adjusts the calculation so that we limit the cache size
to 4k for the acl header+data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 286ab70..6352741 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3737,9 +3737,10 @@ out:
 static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
 {
 	struct nfs4_cached_acl *acl;
+	size_t buflen = sizeof(*acl) + acl_len;
 
-	if (pages && acl_len <= PAGE_SIZE) {
-		acl = kmalloc(sizeof(*acl) + acl_len, GFP_KERNEL);
+	if (pages && buflen <= PAGE_SIZE) {
+		acl = kmalloc(buflen, GFP_KERNEL);
 		if (acl == NULL)
 			goto out;
 		acl->cached = 1;
-- 
1.7.11.2

