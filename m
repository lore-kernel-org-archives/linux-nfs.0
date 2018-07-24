Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f194.google.com ([209.85.215.194]:38066 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388887AbeGXUhl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:41 -0400
Received: by mail-pg1-f194.google.com with SMTP id k3-v6so3572832pgq.5
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:45 -0700 (PDT)
From: Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net, ericvh@gmail.com, rminnich@sandia.gov,
        lucho@ionkov.net, ralf@linux-mips.org, jreuter@yaina.de,
        pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        alex.aring@gmail.com, stefan@datenfreihafen.org,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        johannes@sipsolutions.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, vyasevich@gmail.com,
        nhorman@tuxdriver.com, marcelo.leitner@gmail.com,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au
Cc: netdev@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-hams@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH PATCH net-next 10/18] 9p: fix whitespace issues
Date: Tue, 24 Jul 2018 12:29:10 -0700
Message-Id: <20180724192918.31165-11-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove trailing whitespace and blank lines at EOF

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/9p/client.c       | 4 ++--
 net/9p/trans_virtio.c | 2 +-
 net/9p/util.c         | 1 -
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 5c1343195292..ff02826e0407 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -341,7 +341,7 @@ struct p9_req_t *p9_tag_lookup(struct p9_client *c, u16 tag)
 	 * buffer to read the data into */
 	tag++;
 
-	if(tag >= c->max_tag) 
+	if (tag >= c->max_tag)
 		return NULL;
 
 	row = tag / P9_ROW_MAXTAG;
@@ -1576,7 +1576,7 @@ p9_client_read(struct p9_fid *fid, u64 offset, struct iov_iter *to, int *err)
 		int count = iov_iter_count(to);
 		int rsize, non_zc = 0;
 		char *dataptr;
-			
+
 		rsize = fid->iounit;
 		if (!rsize || rsize > clnt->msize-P9_IOHDRSZ)
 			rsize = clnt->msize - P9_IOHDRSZ;
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 05006cbb3361..279b24488d79 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -446,7 +446,7 @@ p9_virtio_zc_request(struct p9_client *client, struct p9_req_t *req,
 		out += pack_sg_list_p(chan->sg, out, VIRTQUEUE_NUM,
 				      out_pages, out_nr_pages, offs, outlen);
 	}
-		
+
 	/*
 	 * Take care of in data
 	 * For example TREAD have 11.
diff --git a/net/9p/util.c b/net/9p/util.c
index 59f278e64f58..55ad98277e85 100644
--- a/net/9p/util.c
+++ b/net/9p/util.c
@@ -138,4 +138,3 @@ int p9_idpool_check(int id, struct p9_idpool *p)
 	return idr_find(&p->pool, id) != NULL;
 }
 EXPORT_SYMBOL(p9_idpool_check);
-
-- 
2.18.0

