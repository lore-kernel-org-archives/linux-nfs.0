Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from resqmta-po-07v.sys.comcast.net ([96.114.154.166]:37861 "EHLO
        resqmta-po-07v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753223AbcKGPt2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2016 10:49:28 -0500
From: Shuah Khan <shuahkh@osg.samsung.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] net/netfiliter: Fix used uninitialized warn in ip_vs_proc_sync_conn()
Date: Mon,  7 Nov 2016 08:41:13 -0700
Message-Id: <20161107154114.26803-3-shuahkh@osg.samsung.com>
In-Reply-To: <20161107154114.26803-1-shuahkh@osg.samsung.com>
References: <20161107154114.26803-1-shuahkh@osg.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the following warn:

 net/netfilter/ipvs/ip_vs_sync.c: In function ‘ip_vs_proc_sync_conn’:
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.init_seq’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   struct ip_vs_sync_conn_options opt;
                                  ^~~
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘opt.previous_delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).init_seq’ may be used uninitialized in this function [-Wmaybe-uninitialized]
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]
 net/netfilter/ipvs/ip_vs_sync.c:1069:33: warning: ‘*((void *)&opt+12).previous_delta’ may be used uninitialized in this function [-Wmaybe-uninitialized]

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 fs/nfs/nfs4session.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index b629730..68e700e 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -196,7 +196,7 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
 static bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl,
 		u32 slotid, u32 seq_nr)
 {
-	u32 cur_seq;
+	u32 cur_seq = 0;
 	bool ret = false;
 
 	spin_lock(&tbl->slot_tbl_lock);
-- 
2.9.3

