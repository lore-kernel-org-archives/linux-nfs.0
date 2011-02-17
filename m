Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37208 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104Ab1BQEZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 23:25:23 -0500
Date: Wed, 16 Feb 2011 23:25:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 2.6.38 nfsd bugfixes
Message-ID: <20110217042519.GH14534@fieldses.org>
References: <20110215185902.GG29420@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110215185902.GG29420@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Doh--I missed one patch in my previous pull request; see

  git://linux-nfs.org/~bfields/linux.git for-2.6.38

Please apply.

--b.

commit 47c85291d3dd1a51501555000b90f8e281a0458e
Author: NeilBrown <neilb@suse.de>
Date:   Wed Feb 16 13:08:35 2011 +1100

    nfsd: correctly handle return value from nfsd_map_name_to_*
    
    These functions return an nfs status, not a host_err.  So don't
    try to convert  before returning.
    
    This is a regression introduced by
    3c726023402a2f3b28f49b9d90ebf9e71151157d; I fixed up two of the callers,
    but missed these two.
    
    Cc: stable@kernel.org
    Reported-by: Herbert Poetzl <herbert@13thfloor.at>
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 956629b..1275b86 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -317,8 +317,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		READ_BUF(dummy32);
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
-		if ((host_err = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
-			goto out_nfserr;
+		if ((status = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
+			return status;
 		iattr->ia_valid |= ATTR_UID;
 	}
 	if (bmval[1] & FATTR4_WORD1_OWNER_GROUP) {
@@ -328,8 +328,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		READ_BUF(dummy32);
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
-		if ((host_err = nfsd_map_name_to_gid(argp->rqstp, buf, dummy32, &iattr->ia_gid)))
-			goto out_nfserr;
+		if ((status = nfsd_map_name_to_gid(argp->rqstp, buf, dummy32, &iattr->ia_gid)))
+			return status;
 		iattr->ia_valid |= ATTR_GID;
 	}
 	if (bmval[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
