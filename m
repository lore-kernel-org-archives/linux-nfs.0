From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/32] nfs: Keep index within mnt_errtbl[]
Date: Wed, 19 Aug 2009 19:38:24 -0400
Message-ID: <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Roel Kluin <roel.kluin@gmail.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754030AbZHSXlA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:00 -0400
In-Reply-To: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Ensure that index i remains within array mnt_errtbl[] and mnt3_errtbl[].

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/mount_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 38ef9ea..8b9affc 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -258,7 +258,7 @@ static int decode_status(struct xdr_stream *xdr, struct mountres *res)
 		return -EIO;
 	status = ntohl(*p);
 
-	for (i = 0; i <= ARRAY_SIZE(mnt_errtbl); i++) {
+	for (i = 0; i < ARRAY_SIZE(mnt_errtbl); i++) {
 		if (mnt_errtbl[i].status == status) {
 			res->errno = mnt_errtbl[i].errno;
 			return 0;
@@ -309,7 +309,7 @@ static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
 		return -EIO;
 	status = ntohl(*p);
 
-	for (i = 0; i <= ARRAY_SIZE(mnt3_errtbl); i++) {
+	for (i = 0; i < ARRAY_SIZE(mnt3_errtbl); i++) {
 		if (mnt3_errtbl[i].status == status) {
 			res->errno = mnt3_errtbl[i].errno;
 			return 0;
-- 
1.6.0.4
