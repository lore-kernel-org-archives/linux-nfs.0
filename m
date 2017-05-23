Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032015AbdEWVow (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 17:44:52 -0400
Date: Tue, 23 May 2017 17:44:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: trond.myklebust@primarydata.com, stable@vger.kernel.org,
        stable-commits@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix up the "supattr_exclcreat" attributes
Message-ID: <20170523214449.GI7556@parsley.fieldses.org>
References: <14955646521694@kroah.com>
 <20170523192339.GA30111@kroah.com>
 <20170523203824.GG7556@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170523203824.GG7556@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

commit b26b78cb726007533d81fdf90a62e915002ef5c8 upstream

If an NFSv4 client asks us for the supattr_exclcreat, then we must
not return attributes that are unsupported by this minor version.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: 75976de6556f ("NFSD: Return word2 bitmask if setting security..,")
[bfields: use old functions instead of new array in stable backport]
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

On Tue, May 23, 2017 at 04:38:24PM -0400, J. Bruce Fields wrote:
> The issue is
> 
> 	916d2d844afd "nfsd: clean up supported attribute handling"
> 	dcd208697707 "nfsd: fix supported attributes for acl & labels"
> 
> which replaced 3 numbered constants by an array, and went in between 4.8
> and 4.10.
> 
> But for the purposes of older stable branches, best is probably just to
> use the old constants.  I'll send an updated patch.

Here it is.  This should do for 4.9 and older stable branches.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 12935209deca..37d30e5caf46 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2753,9 +2753,16 @@ out_acl:
 	}
 #endif /* CONFIG_NFSD_PNFS */
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
-		status = nfsd4_encode_bitmap(xdr, NFSD_SUPPATTR_EXCLCREAT_WORD0,
-						  NFSD_SUPPATTR_EXCLCREAT_WORD1,
-						  NFSD_SUPPATTR_EXCLCREAT_WORD2);
+		u32 supp[3];
+
+		supp[0] = nfsd_suppattrs0(minorversion);
+		supp[1] = nfsd_suppattrs1(minorversion);
+		supp[2] = nfsd_suppattrs2(minorversion);
+		supp[0] &= NFSD_SUPPATTR_EXCLCREAT_WORD0;
+		supp[1] &= NFSD_SUPPATTR_EXCLCREAT_WORD1;
+		supp[2] &= NFSD_SUPPATTR_EXCLCREAT_WORD2;
+
+		status = nfsd4_encode_bitmap(xdr, supp[0], supp[1], supp[2]);
 		if (status)
 			goto out;
 	}
-- 
2.9.3

