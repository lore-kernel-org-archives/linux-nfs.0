Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21819 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758763Ab1D0Tr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 15:47:26 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/3] NFSD: Remove unused variable from nfsd4_decode_bind_conn_to_session()
Date: Wed, 27 Apr 2011 15:47:16 -0400
Message-Id: <1303933636-22134-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
References: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

Compiling gave me this warning:
fs/nfsd/nfs4xdr.c: In function ‘nfsd4_decode_bind_conn_to_session’:
fs/nfsd/nfs4xdr.c:427:6: warning: variable ‘dummy’ set but not used
[-Wunused-but-set-variable]

The local variable "dummy" wasn't being used past the READ32() macro that
set it.  READ_BUF() should ensure that the xdr buffer is pushed past the
data read into dummy already, so nothing needs to be read in.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6766af..6191eec 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -424,14 +424,12 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
 static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp, struct nfsd4_bind_conn_to_session *bcts)
 {
 	DECODE_HEAD;
-	u32 dummy;
 
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 8);
 	COPYMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	READ32(bcts->dir);
 	/* XXX: Perhaps Tom Tucker could help us figure out how we
 	 * should be using ctsa_use_conn_in_rdma_mode: */
-	READ32(dummy);
 
 	DECODE_TAIL;
 }
-- 
1.7.4.4

