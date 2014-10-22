Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbaJVTtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:49:12 -0400
Date: Wed, 22 Oct 2014 15:49:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] nfsd4: fix crash on unknown operation number
Message-ID: <20141022194907.GD5552@fieldses.org>
References: <20141017212446.GC3474@fieldses.org>
 <20141021103631.GB21863@infradead.org>
 <20141021131406.GE9863@fieldses.org>
 <20141022192258.GB5552@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141022192258.GB5552@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Unknown operation numbers are caught in nfsd4_decode_compound() which
sets op->opnum to OP_ILLEGAL and op->status to nfserr_op_illegal.  The
error causes the main loop in nfsd4_proc_compound() to skip most
processing.  But nfsd4_proc_compound also peeks ahead at the next
operation in one case and doesn't take similar precautions there.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

On Wed, Oct 22, 2014 at 03:2
> There are two bugs:
> 
> 	- the client is sending SEEK over minorversion 1.
> 	- this sometimes causes the server to crash.
> 
> I'm testing a fix for the latter.

I think this is all it needs.

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f4bd578bed55..0beb023f25ac 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1272,7 +1272,8 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	 */
 	if (argp->opcnt == resp->opcnt)
 		return false;
-
+	if (next->opnum == OP_ILLEGAL)
+		return false;
 	nextd = OPDESC(next);
 	/*
 	 * Rest of 2.6.3.1.1: certain operations will return WRONGSEC
-- 
1.9.3

