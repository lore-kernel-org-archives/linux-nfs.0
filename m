Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab2DZVDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFSv4: Fix a typo in NFS4_enc_link_sz
Date: Thu, 26 Apr 2012 17:03:28 -0400
Message-Id: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0d2a1e6..5edf936 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -626,9 +626,9 @@ static int nfs4_stat_to_errno(int);
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
 				encode_link_maxsz + \
-				decode_getattr_maxsz + \
+				encode_getattr_maxsz + \
 				encode_restorefh_maxsz + \
-				decode_getattr_maxsz)
+				encode_getattr_maxsz)
 #define NFS4_dec_link_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-- 
1.7.7.6

