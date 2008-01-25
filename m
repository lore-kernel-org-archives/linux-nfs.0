From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 040/112] NFS: Change sign of some loop indices in nfs4xdr.c
Date: Fri, 25 Jan 2008 11:37:35 -0500
Message-ID: <20080125163735.31887.26192.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185AbYAYQ74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:56 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseQ010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:55 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Nit: Eliminate some mixed sign comparisons in loop indices.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2e1fe17..eae46f0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2515,14 +2515,12 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 
 static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 {
-	int n;
+	u32 n;
 	__be32 *p;
 	int status = 0;
 
 	READ_BUF(4);
 	READ32(n);
-	if (n < 0)
-		goto out_eio;
 	if (n == 0)
 		goto root_path;
 	dprintk("path ");
@@ -2579,13 +2577,11 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		goto out_eio;
 	res->nlocations = 0;
 	while (res->nlocations < n) {
-		int m;
+		u32 m;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
 		READ32(m);
-		if (m <= 0)
-			goto out_eio;
 
 		loc->nservers = 0;
 		dprintk("%s: servers ", __FUNCTION__);
@@ -2598,8 +2594,12 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			if (loc->nservers < NFS4_FS_LOCATION_MAXSERVERS)
 				loc->nservers++;
 			else {
-				int i;
-				dprintk("%s: using first %d of %d servers returned for location %d\n", __FUNCTION__, NFS4_FS_LOCATION_MAXSERVERS, m, res->nlocations);
+				unsigned int i;
+				dprintk("%s: using first %u of %u servers "
+					"returned for location %u\n",
+						__FUNCTION__,
+						NFS4_FS_LOCATION_MAXSERVERS,
+						m, res->nlocations);
 				for (i = loc->nservers; i < m; i++) {
 					unsigned int len;
 					char *data;
