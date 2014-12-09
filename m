Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46409 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbaLIRhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 12:37:11 -0500
Date: Tue, 9 Dec 2014 12:37:10 -0500
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd4: fix xdr4 count of server in fs_location4
Message-ID: <20141209173710.GM20526@fieldses.org>
References: <cover.1417985975.git.bcodding@redhat.com>
 <d602d4a37d02801659ddf5e6f012453b89169f70.1417985975.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d602d4a37d02801659ddf5e6f012453b89169f70.1417985975.git.bcodding@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 07, 2014 at 04:05:48PM -0500, Benjamin Coddington wrote:
> Fix a bug where nfsd4_encode_components_esc() incorrectly calculates the
> length of server array in fs_location4.

Thanks, applying as follows.

This is something I don't test regularly but should.

--b.

commit 3e376626896b
Author: Benjamin Coddington <bcodding@redhat.com>
Date:   Sun Dec 7 16:05:48 2014 -0500

    nfsd4: fix xdr4 count of server in fs_location4
    
    Fix a bug where nfsd4_encode_components_esc() incorrectly calculates the
    length of server array in fs_location4--note that it is a count of the
    number of array elements, not a length in bytes.
    
    Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
    Fixes: 082d4bd72a45 (nfsd4: "backfill" using write_bytes_to_xdr_buf)
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a8549f8fef57..e578c87d5527 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1817,7 +1817,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
 
 		str = end;
 	}
-	pathlen = htonl(xdr->buf->len - pathlen_offset);
+	pathlen = htonl(count);
 	write_bytes_to_xdr_buf(xdr->buf, pathlen_offset, &pathlen, 4);
 	return 0;
 }
