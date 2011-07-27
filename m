Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:42040 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab1G0LC4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 07:02:56 -0400
Subject: [PATCH 2/3] Remove check for a 32-bit cookie in nfsd4_readdir()
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Date: Wed, 27 Jul 2011 13:02:54 +0200
Message-ID: <20110727110254.204979.34074.stgit@localhost.localdomain>
In-Reply-To: <20110727110148.204979.49551.stgit@localhost.localdomain>
References: <20110727110148.204979.49551.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fan Yong <yong.fan@whamcloud.com>  noticed simply setting
O_64BITHASH wouldn't work with nfsd v4, as
nfsd4_readdir() checks for a 32 bit cookie. However, according to RFC 3530
cookies have a 64 bit type and it is also defined as u64
'struct nfsd4_readdir'.
So remove the test for >32-bit values.

Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 fs/nfsd/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a6dbd7..f7799d3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -682,7 +682,7 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	readdir->rd_bmval[1] &= nfsd_suppattrs1(cstate->minorversion);
 	readdir->rd_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
 
-	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
+	if ((cookie == 1) || (cookie == 2) ||
 	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
 		return nfserr_bad_cookie;
 

