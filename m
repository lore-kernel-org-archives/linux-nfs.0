Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:38012 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab1HHPiK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 11:38:10 -0400
Subject: [PATCH 3/4] RFC: Remove check for a 32-bit cookie in nfsd4_readdir()
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Date: Mon, 08 Aug 2011 17:38:08 +0200
Message-ID: <20110808153808.1872437.85162.stgit@fsdevel3>
In-Reply-To: <20110808153432.1872437.85783.stgit@fsdevel3>
References: <20110808153432.1872437.85783.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fan Yong <yong.fan@whamcloud.com> noticed setting
FMODE_32bithash wouldn't work with nfsd v4, as
nfsd4_readdir() checks for 32 bit cookies. However, according to RFC 3530
cookies have a 64 bit type and cookies are also defined as u64 in
'struct nfsd4_readdir'. So remove the test for >32-bit values.

Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 fs/nfsd/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e807776..9bf0a66 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -691,7 +691,7 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	readdir->rd_bmval[1] &= nfsd_suppattrs1(cstate->minorversion);
 	readdir->rd_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
 
-	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
+	if ((cookie == 1) || (cookie == 2) ||
 	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
 		return nfserr_bad_cookie;
 

