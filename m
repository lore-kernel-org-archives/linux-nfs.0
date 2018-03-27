Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:54108 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbeC0Owu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:52:50 -0400
Received: by mail-it0-f68.google.com with SMTP id m134-v6so10825080itb.3
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:52:50 -0700 (PDT)
Subject: [PATCH v2 11/18] nfsd: Fix NFSD trace points
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:52:43 -0400
Message-ID: <20180327145243.7710.61728.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd-1915  [003] 77915.780959: write_opened:
	[FAILED TO PARSE] xid=3286130958 fh=0 offset=154624 len=1
nfsd-1915  [003] 77915.780960: write_io_done:
	[FAILED TO PARSE] xid=3286130958 fh=0 offset=154624 len=1
nfsd-1915  [003] 77915.780964: write_done:
	[FAILED TO PARSE] xid=3286130958 fh=0 offset=154624 len=1

Byte swapping and knfsd_fh_hash() are not available in "trace-cmd
report", where the print format string is actually used. These
data transformations have to be done during the TP_fast_assign step.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 8b2f1d9..3aa3f3b 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -18,19 +18,24 @@
 		 int		len),
 	TP_ARGS(rqstp, fhp, offset, len),
 	TP_STRUCT__entry(
-		__field(__be32, xid)
-		__field_struct(struct knfsd_fh, fh)
+		__field(u32, xid)
+		__field(u32, fh_hash)
 		__field(loff_t, offset)
 		__field(int, len)
 	),
 	TP_fast_assign(
-		__entry->xid = rqstp->rq_xid,
-		fh_copy_shallow(&__entry->fh, &fhp->fh_handle);
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		do {
+			struct knfsd_fh fh;
+
+			fh_copy_shallow(&fh, &fhp->fh_handle);
+			__entry->fh_hash = knfsd_fh_hash(&fh);
+		} while (0);
 		__entry->offset = offset;
 		__entry->len = len;
 	),
-	TP_printk("xid=0x%x fh=0x%x offset=%lld len=%d",
-		  __be32_to_cpu(__entry->xid), knfsd_fh_hash(&__entry->fh),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%lld len=%d",
+		  __entry->xid, __entry->fh_hash,
 		  __entry->offset, __entry->len)
 )
 

