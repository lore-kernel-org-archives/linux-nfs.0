Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga01-in.huawei.com ([119.145.14.64]:29267 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162Ab3JNM2e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 08:28:34 -0400
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: John McCutchan <john@johnmccutchan.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Paris <eparis@redhat.com>, Robert Love <rlove@rlove.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] fs: nfsd: use path_equal() to simply code
Date: Mon, 14 Oct 2013 20:26:01 +0800
Message-ID: <1381753562-47884-3-git-send-email-wangkefeng.wang@huawei.com>
In-Reply-To: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
References: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 fs/nfsd/export.c  | 3 +--
 fs/nfsd/nfs4xdr.c | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5f38ea3..ca3610d 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -649,8 +649,7 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 	struct svc_export *orig = container_of(a, struct svc_export, h);
 	struct svc_export *new = container_of(b, struct svc_export, h);
 	return orig->ex_client == new->ex_client &&
-		orig->ex_path.dentry == new->ex_path.dentry &&
-		orig->ex_path.mnt == new->ex_path.mnt;
+		path_equal(&orig->ex_path, &new->ex_path);
 }
 
 static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d9454fe..6af4ff1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1829,7 +1829,7 @@ static __be32 nfsd4_encode_path(const struct path *root,
 	 * dentries/path components in an array.
 	 */
 	for (;;) {
-		if (cur.dentry == root->dentry && cur.mnt == root->mnt)
+		if (path_equal(&cur, root))
 			break;
 		if (cur.dentry == cur.mnt->mnt_root) {
 			if (follow_up(&cur))
-- 
1.8.2.1


