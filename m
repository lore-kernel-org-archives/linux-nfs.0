Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46859 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758314Ab2C1PJm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:09:42 -0400
Subject: [PATCH 6/8] nfsd: use hash table from cache detail in nfsd export seq
 ops
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 28 Mar 2012 19:09:35 +0400
Message-ID: <20120328150935.2646.18885.stgit@localhost6.localdomain6>
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hard-code is redundant and will prevent from making caches per net ns.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 1495320..9fe7156 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1035,6 +1035,7 @@ static void *e_start(struct seq_file *m, loff_t *pos)
 	unsigned hash, export;
 	struct cache_head *ch;
 	struct cache_detail *cd = m->private;
+	struct cache_head **export_table = cd->hash_table;
 
 	read_lock(&cd->hash_lock);
 	if (!n--)
@@ -1061,6 +1062,8 @@ static void *e_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	struct cache_head *ch = p;
 	int hash = (*pos >> 32);
+	struct cache_detail *cd = m->private;
+	struct cache_head **export_table = cd->hash_table;
 
 	if (p == SEQ_START_TOKEN)
 		hash = 0;

