Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34679 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbbH1Apu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 20:45:50 -0400
Received: by igui7 with SMTP id i7so7122770igu.1
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2015 17:45:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1/pnfs: Ensure layoutreturn reserves space for the opaque payload
Date: Thu, 27 Aug 2015 20:45:47 -0400
Message-Id: <1440722747-124599-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440722747-124599-1-git-send-email-trond.myklebust@primarydata.com>
References: <1440722747-124599-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "FIXME" is outdated. Flexfiles does add a payload.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a7be571c1666..ff4784c54e04 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -400,7 +400,8 @@ static int nfs4_stat_to_errno(int);
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
 #define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
 				encode_stateid_maxsz + \
-				1 /* FIXME: opaque lrf_body always empty at the moment */)
+				1 + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
 #define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
 				1 + decode_stateid_maxsz)
 #define encode_secinfo_no_name_maxsz (op_encode_hdr_maxsz + 1)
-- 
2.4.3

