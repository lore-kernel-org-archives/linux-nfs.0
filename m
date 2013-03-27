Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:8979 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751390Ab3C0EVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 00:21:15 -0400
Message-ID: <515273CC.6030209@cn.fujitsu.com>
Date: Wed, 27 Mar 2013 12:21:32 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v1] nfs: nfs client decode fslocations oops if server cheating
 it
References: <51502DB7.1010508@cn.fujitsu.com>
In-Reply-To: <51502DB7.1010508@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

now nfs server will return wrong nlocations,nservers, ncomponents to 
the client.for example if the nlocations is NFS4_FS_LOCATIONS_MAXENTRIES, 
the nfs client will decode oops when run "struct nfs4_fs_location *loc 
= &res->locations[res->nlocations]"

#################################################################

3599     if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
3600           res->nlocations++;

#################################################################

i see if  res->nlocations is  NFS4_FS_LOCATIONS_MAXENTRIES -1, then next it will
run res->nlocations++ and  res->nlocations will be NFS4_FS_LOCATIONS_MAXENTRIES.
if res->nlocations is NFS4_FS_LOCATIONS_MAXENTRIES , it maybe oops when run following
code.

#################################################################
...snip...

3562                 u32 m;
3563                 ★ struct nfs4_fs_location *loc = &res->locations[res->nlocations]; ★<--bug ,max location is NFS4_FS_LOCATIONS_MAXENTRIES-1,but now res->nlocations is NFS4_FS_LOCATIONS_MAXENTRIES

35
3565                 p = xdr_inline_decode(xdr, 4);
3566                 if (unlikely(!p))
3567                         goto out_overflow;
3568                 m = be32_to_cpup(p);
3569 
3570                 ★ loc->nservers = 0;<--it maybe cause oops.
...snip...


#################################################

Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>

---
 fs/nfs/nfs4xdr.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e3edda5..25f1769 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3496,6 +3496,10 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	n = be32_to_cpup(p);
 	if (n == 0)
 		goto root_path;
+	if (n > NFS4_PATHNAME_MAXCOMPONENTS) {
+		dprintk("%s: server cheating client ncomponents :%d\n", __func__, n);
+		goto out_eio;
+	}
 	dprintk("pathname4: ");
 	path->ncomponents = 0;
 	while (path->ncomponents < n) {
@@ -3557,6 +3561,10 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	n = be32_to_cpup(p);
 	if (n <= 0)
 		goto out_eio;
+	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
+		dprintk("%s: server cheating client nlocations :%d\n", __func__, n);
+		goto out_eio;
+	}
 	res->nlocations = 0;
 	while (res->nlocations < n) {
 		u32 m;
@@ -3566,7 +3574,10 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		if (unlikely(!p))
 			goto out_overflow;
 		m = be32_to_cpup(p);
-
+		if (m > NFS4_FS_LOCATION_MAXSERVERS) {
+			dprintk("%s: server cheating client nservers :%d\n", __func__, m);
+			goto out_eio;
+		}
 		loc->nservers = 0;
 		dprintk("%s: servers:\n", __func__);
 		while (loc->nservers < m) {
-- 1.7.1 --

