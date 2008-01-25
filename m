From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 015/100] nfsd: Fix handling of negative lengths in read_buf()
Date: Fri, 25 Jan 2008 18:15:55 -0500
Message-ID: <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47323 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762016AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The length "nbytes" passed into read_buf should never be negative, but
we check only for too-large values of "nbytes", not for too-small
values.  Make nbytes unsigned, so it's clear that the former tests are
sufficient.  (Despite this read_buf() currently correctly returns an xdr
error in the case of a negative length, thanks to an unsigned
comparison with size_of() and bounds-checking in kmalloc().  This seems
very fragile, though.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4xdr.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5733394..25c7ae2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -148,7 +148,7 @@ xdr_error:					\
 	}					\
 } while (0)
 
-static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
+static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
 	 * Maybe we need a new page, maybe we have just run out
@@ -169,6 +169,11 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
 			return NULL;
 		
 	}
+	/*
+	 * The following memcpy is safe because read_buf is always
+	 * called with nbytes > avail, and the two cases above both
+	 * guarantee p points to at least nbytes bytes.
+	 */
 	memcpy(p, argp->p, avail);
 	/* step to next page */
 	argp->p = page_address(argp->pagelist[0]);
-- 
1.5.4.rc2.60.gb2e62

