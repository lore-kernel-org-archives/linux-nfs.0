From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] nfsd: kill unused ENT_HASHMASK definition
Date: Fri, 14 Jan 2011 16:39:04 +0800
Message-ID: <4D300BA8.80000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64306 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752334Ab1ANIlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 03:41:55 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This macro definition has not been using since v2.6.12-rc2.
So, remove it now.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 fs/nfsd/nfs4idmap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index f0695e8..ce0f6b9 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -62,7 +62,6 @@ struct ent {
 
 #define ENT_HASHBITS          8
 #define ENT_HASHMAX           (1 << ENT_HASHBITS)
-#define ENT_HASHMASK          (ENT_HASHMAX - 1)
 
 static void
 ent_init(struct cache_head *cnew, struct cache_head *citm)
-- 
1.6.3.3
