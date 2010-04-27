Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53297 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757159Ab0D0Vcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 17:32:32 -0400
Date: Tue, 27 Apr 2010 17:32:30 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: nfsd bugfix for 2.6.34
Message-ID: <20100427213230.GD3831@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The following nfsd bugfix is available from

  git://linux-nfs.org/~bfields/linux.git for-2.6.34

Please pull for 2.6.34.  Thanks!

--b.

commit 2bc3c1179c781b359d4f2f3439cb3df72afc17fc
Author: Neil Brown <neilb@suse.de>
Date:   Tue Apr 20 12:16:52 2010 +1000

    nfsd4: bug in read_buf
    
    When read_buf is called to move over to the next page in the pagelist
    of an NFSv4 request, it sets argp->end to essentially a random
    number, certainly not an address within the page which argp->p now
    points to.  So subsequent calls to READ_BUF will think there is much
    more than a page of spare space (the cast to u32 ensures an unsigned
    comparison) so we can expect to fall off the end of the second
    page.
    
    We never encountered thsi in testing because typically the only
    operations which use more than two pages are write-like operations,
    which have their own decoding logic.  Something like a getattr after a
    write may cross a page boundary, but it would be very unusual for it to
    cross another boundary after that.
    
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e170317..34ccf81 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -161,10 +161,10 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	argp->p = page_address(argp->pagelist[0]);
 	argp->pagelist++;
 	if (argp->pagelen < PAGE_SIZE) {
-		argp->end = p + (argp->pagelen>>2);
+		argp->end = argp->p + (argp->pagelen>>2);
 		argp->pagelen = 0;
 	} else {
-		argp->end = p + (PAGE_SIZE>>2);
+		argp->end = argp->p + (PAGE_SIZE>>2);
 		argp->pagelen -= PAGE_SIZE;
 	}
 	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
@@ -1426,10 +1426,10 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 			argp->p = page_address(argp->pagelist[0]);
 			argp->pagelist++;
 			if (argp->pagelen < PAGE_SIZE) {
-				argp->end = p + (argp->pagelen>>2);
+				argp->end = argp->p + (argp->pagelen>>2);
 				argp->pagelen = 0;
 			} else {
-				argp->end = p + (PAGE_SIZE>>2);
+				argp->end = argp->p + (PAGE_SIZE>>2);
 				argp->pagelen -= PAGE_SIZE;
 			}
 		}
