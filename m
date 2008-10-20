From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NFSD deferral processing
Date: Mon, 20 Oct 2008 13:58:44 -0400
Message-ID: <20081020175844.GA23927@fieldses.org>
References: <1224104426-12293-1-git-send-email-andros@netapp.com> <1224104426-12293-2-git-send-email-andros@netapp.com> <1224104426-12293-3-git-send-email-andros@netapp.com> <1224104426-12293-4-git-send-email-andros@netapp.com> <RTPCLUEXC1-PRDNY30k000001cc@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56727 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751518AbYJTR6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 13:58:47 -0400
In-Reply-To: <RTPCLUEXC1-PRDNY30k000001cc-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 04:46:50PM -0400, Talpey, Thomas wrote:
> At 05:00 PM 10/15/2008, andros@netapp.com wrote:
> >From: Andy Adamson <andros@netapp.com>
> >
> >Use a slab cache for nfsd4_compound_state allocation
> >
> >Save the struct nfsd4_compound_state and set the save_state callback for
> >each request for potential deferral handling.
> >
> >If an NFSv4 operation causes a deferral, the save_state callback is called
> >by svc_defer which saves the defer_data with the deferral, and sets the
> >restore_state deferral callback.
> >
> >fh_put is called so that the deferral is not referencing the file handles,
> >allowing umount of the file system.
> 
> Can you explain the safety of this? If the COMPOUND starts off with an
> operation that uses them, what's the implication of one going stale
> partway through?

I suppose it means the compound could get an unexpected STALE error
partway through.

> Is fh_verify() when the deferral continues enough to
> ensure the fh is protected until the end of the op?

I'm not sure what you mean.

> There's a comment at the top of fh_verify() that it is "only called at
> the start of an nfsproc call", with some assumptions, for instance.

That comment could be improved.

--b.

commit 438d5d3ec385e6385856929719322d569de3e148
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Oct 20 13:01:59 2008 -0400

    nfsd: update fh_verify description

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index cd25d91..8cabcfa 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -253,14 +253,32 @@ out:
 	return error;
 }
 
-/*
- * Perform sanity checks on the dentry in a client's file handle.
+/**
+ * fh_verify - filehandle lookup and access checking
+ * @rqstp: pointer to current rpc request
+ * @fhp: filehandle to be verified
+ * @type: expected type of object pointed to by filehandle
+ * @access: type of access needed to object
+ *
+ * Look up a dentry from the on-the-wire filehandle, check the client's
+ * access to the export, and set the current task's credentials.
+ *
+ * Regardless of success or failure of fh_verify(), fh_put() should be
+ * called on @fhp when the caller is finished with the filehandle.
+ *
+ * fh_verify() may be called multiple times on a given filehandle, for
+ * example, when processing an NFSv4 compound.  The first call will look
+ * up a dentry using the on-the-wire filehandle.  Subsequent calls will
+ * skip the lookup and just perform the other checks and possibly change
+ * the current task's credentials.
  *
- * Note that the file handle dentry may need to be freed even after
- * an error return.
+ * @type specifies the type of object expected using one of the S_IF*
+ * constants defined in include/linux/stat.h.  The caller may use zero
+ * to indicate that it doesn't care, or a negative integer to indicate
+ * that it expects something not of the given type.
  *
- * This is only called at the start of an nfsproc call, so fhp points to
- * a svc_fh which is all 0 except for the over-the-wire file handle.
+ * @access is formed from the NFSD_MAY_* constants defined in
+ * include/linux/nfsd/nfsd.h.
  */
 __be32
 fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
