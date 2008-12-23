From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 48/69] nfs: return compound hdr.status when there are no op
 replies
Date: Tue, 23 Dec 2008 18:02:20 -0500
Message-ID: <20081223230219.13743.88726.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732AbYLWXYk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:40 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSg021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

When there are no op replies encoded in the compound reply
hdr.status still contains the overall status of the compound
rpc.  This can happen, e.g., when the server returns a
NFS4ERR_MINOR_VERS_MISMATCH error.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d8ddfc5..3f18a26 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2222,6 +2222,8 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	READ32(hdr->nops);
+	if (unlikely(hdr->nops < 1))
+		return nfs4_stat_to_errno(hdr->status);
 	return 0;
 }
 

