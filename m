Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55170 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907Ab1KBWcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 18:32:16 -0400
Date: Wed, 2 Nov 2011 18:32:13 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
Subject: nfsd typo fix for 3.2
Message-ID: <20111102223213.GC12883@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got one typo fix in for-3.2 branch at:

  git://linux-nfs.org/~bfields/linux.git for-3.2

Please pull--and thanks to Benny for catching it!

--b.

Benny Halevy (1):
      nfsd4: typo logical vs bitwise negate in nfsd4_decode_share_access

 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

commit fc0d14fe2d6403eb21202fd0c1cf67cd2c85ca67
Author: Benny Halevy <bhalevy@tonian.com>
Date:   Thu Oct 27 20:43:01 2011 +0200

    nfsd4: typo logical vs bitwise negate in nfsd4_decode_share_access
    
    Signed-off-by: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 66d095d..b6fa792 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -655,7 +655,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	default:
 		return nfserr_bad_xdr;
 	}
-	w &= !NFS4_SHARE_ACCESS_MASK;
+	w &= ~NFS4_SHARE_ACCESS_MASK;
 	if (!w)
 		return nfs_ok;
 	if (!argp->minorversion)
