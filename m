Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615Ab2D2UuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 01/15] NFSv4: Fix a typo in NFS4_enc_link_sz
Date: Sun, 29 Apr 2012 16:50:06 -0400
Message-Id: <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4c3cc0e..fe61424 100644
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

