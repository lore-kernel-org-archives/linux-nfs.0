From: andros@netapp.com
Subject: [PATCH 4/5] nfsd41: set the session maximum response size cached
Date: Wed, 24 Jun 2009 15:37:48 -0400
Message-ID: <1245872278-18743-5-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967AbZFXTiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:00 -0400
In-Reply-To: <1245872278-18743-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSD_SLOT_CACHE_SIZE holds the encoded operations past the SEQUENCE operation.
ca_maxresponsesize_cached (draft-ietf-nfsv4-minorversion1-29) is the xdr
encoded size of the request including the RPC header. Since the RPC header
size varies with security flavor credential and verifier. we cannot set an
accurate ca_maxresponsesize_cached. Use NFSD_SLOT_CACHE_SIZE as an
approximate ca_maxresponsesize_cached - we will have at least that much space.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 991c3cc..a0bd6da 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -464,9 +464,14 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxresp_sz = maxcount;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
-	/* Set the max response cached size our default which is
-	 * a multiple of PAGE_SIZE and small */
-	session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
+	/*
+	 * The ca_maxresponssize_cached definition includes the xdr
+	 * encoded size of the rpc header with the variable length security
+	 * flavor credential plus verifier as well as the encoded SEQUENCE
+	 * operation response size which are not included in
+	 * NFSD_SLOT_CACHE_SIZE. We err on the side of being a bit small.
+	 */
+	session_fchan->maxresp_cached = NFSD_SLOT_CACHE_SIZE;
 	fchan->maxresp_cached = session_fchan->maxresp_cached;
 
 	/* Use the client's maxops if possible */
-- 
1.5.4.3

