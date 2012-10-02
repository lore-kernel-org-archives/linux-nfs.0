Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:50640 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab2JBFfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 01:35:24 -0400
Date: Tue, 2 Oct 2012 13:09:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: kernel-janitors@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [nfs:nfs-for-next 76/83] fs/nfs/blocklayout/blocklayout.c:1208:1:
 sparse: symbol 'bl_pg_init_write' was not declared. Should it be static?
Message-ID: <20121002050951.GA18119@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Peng,

FYI, there are new sparse warnings show up in

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-next
head:   2afdfa5a846246de50e1881f71ba5c0aac0b415f
commit: 96c9eae638765c2bf2ca4f5a6325484f9bb69aa7 [76/83] pnfsblock: fix non-aligned DIO write

+ fs/nfs/blocklayout/blocklayout.c:1208:1: sparse: symbol 'bl_pg_init_write' was not declared. Should it be static?

vim +1208 fs/nfs/blocklayout/blocklayout.c

155e7524 (Fred Isaman 2011-07-30  1176) 	return 0;
155e7524 (Fred Isaman 2011-07-30  1177) }
155e7524 (Fred Isaman 2011-07-30  1178) 
f742dc4a (Peng Tao    2012-08-24  1179) static bool
f742dc4a (Peng Tao    2012-08-24  1180) is_aligned_req(struct nfs_page *req, unsigned int alignment)
f742dc4a (Peng Tao    2012-08-24  1181) {
f742dc4a (Peng Tao    2012-08-24  1182) 	return IS_ALIGNED(req->wb_offset, alignment) &&
f742dc4a (Peng Tao    2012-08-24  1183) 	       IS_ALIGNED(req->wb_bytes, alignment);
f742dc4a (Peng Tao    2012-08-24  1184) }
f742dc4a (Peng Tao    2012-08-24  1185) 
f742dc4a (Peng Tao    2012-08-24  1186) static void
f742dc4a (Peng Tao    2012-08-24  1187) bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
f742dc4a (Peng Tao    2012-08-24  1188) {
f742dc4a (Peng Tao    2012-08-24  1189) 	if (pgio->pg_dreq != NULL &&
f742dc4a (Peng Tao    2012-08-24  1190) 	    !is_aligned_req(req, SECTOR_SIZE))
f742dc4a (Peng Tao    2012-08-24  1191) 		nfs_pageio_reset_read_mds(pgio);
f742dc4a (Peng Tao    2012-08-24  1192) 	else
f742dc4a (Peng Tao    2012-08-24  1193) 		pnfs_generic_pg_init_read(pgio, req);
f742dc4a (Peng Tao    2012-08-24  1194) }
f742dc4a (Peng Tao    2012-08-24  1195) 
f742dc4a (Peng Tao    2012-08-24  1196) static bool
f742dc4a (Peng Tao    2012-08-24  1197) bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
f742dc4a (Peng Tao    2012-08-24  1198) 		struct nfs_page *req)
f742dc4a (Peng Tao    2012-08-24  1199) {
f742dc4a (Peng Tao    2012-08-24  1200) 	if (pgio->pg_dreq != NULL &&
f742dc4a (Peng Tao    2012-08-24  1201) 	    !is_aligned_req(req, SECTOR_SIZE))
f742dc4a (Peng Tao    2012-08-24  1202) 		return false;
f742dc4a (Peng Tao    2012-08-24  1203) 
f742dc4a (Peng Tao    2012-08-24  1204) 	return pnfs_generic_pg_test(pgio, prev, req);
f742dc4a (Peng Tao    2012-08-24  1205) }
f742dc4a (Peng Tao    2012-08-24  1206) 
96c9eae6 (Peng Tao    2012-08-24  1207) void
96c9eae6 (Peng Tao    2012-08-24 @1208) bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
96c9eae6 (Peng Tao    2012-08-24  1209) {
96c9eae6 (Peng Tao    2012-08-24  1210) 	if (pgio->pg_dreq != NULL &&
96c9eae6 (Peng Tao    2012-08-24  1211) 	    !is_aligned_req(req, PAGE_CACHE_SIZE))
96c9eae6 (Peng Tao    2012-08-24  1212) 		nfs_pageio_reset_write_mds(pgio);
96c9eae6 (Peng Tao    2012-08-24  1213) 	else
96c9eae6 (Peng Tao    2012-08-24  1214) 		pnfs_generic_pg_init_write(pgio, req);
96c9eae6 (Peng Tao    2012-08-24  1215) }
96c9eae6 (Peng Tao    2012-08-24  1216) 
96c9eae6 (Peng Tao    2012-08-24  1217) static bool
96c9eae6 (Peng Tao    2012-08-24  1218) bl_pg_test_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
96c9eae6 (Peng Tao    2012-08-24  1219) 		 struct nfs_page *req)
96c9eae6 (Peng Tao    2012-08-24  1220) {
96c9eae6 (Peng Tao    2012-08-24  1221) 	if (pgio->pg_dreq != NULL &&
96c9eae6 (Peng Tao    2012-08-24  1222) 	    !is_aligned_req(req, PAGE_CACHE_SIZE))
96c9eae6 (Peng Tao    2012-08-24  1223) 		return false;
96c9eae6 (Peng Tao    2012-08-24  1224) 

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--GvXjxJ+pjyke8COw
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="make-it-static-96c9eae.diff"

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index af3ef0e..a34014a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1204,7 +1204,7 @@ bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
 
-void
+static void
 bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&

--GvXjxJ+pjyke8COw--
