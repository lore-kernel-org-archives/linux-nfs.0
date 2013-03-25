Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:19634 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757325Ab3CYK56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 06:57:58 -0400
Message-ID: <51502DB7.1010508@cn.fujitsu.com>
Date: Mon, 25 Mar 2013 18:57:59 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: nfs client decode fslocations oops if server cheating
 it
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

now nfs server will return wrong nlocations,nservers, ncomponents to the client.
for example if the nlocations is NFS4_FS_LOCATIONS_MAXENTRIES, the nfs client
will decode oops when run "struct nfs4_fs_location *loc = &res->locations[res->nlocations]"

Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
Reviewed-by: chendt.fnst@cn.fujitsu.com

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
-- 
1.7.1


