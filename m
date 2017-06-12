Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55428 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751920AbdFLHkR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jun 2017 03:40:17 -0400
Date: Mon, 12 Jun 2017 09:40:11 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: trond.myklebust@primarydata.com, stable@vger.kernel.org,
        stable-commits@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix up the "supattr_exclcreat" attributes
Message-ID: <20170612074010.GA19902@kroah.com>
References: <14955646521694@kroah.com>
 <20170523192339.GA30111@kroah.com>
 <20170523203824.GG7556@parsley.fieldses.org>
 <20170523214449.GI7556@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170523214449.GI7556@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 23, 2017 at 05:44:50PM -0400, J. Bruce Fields wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> commit b26b78cb726007533d81fdf90a62e915002ef5c8 upstream
> 
> If an NFSv4 client asks us for the supattr_exclcreat, then we must
> not return attributes that are unsupported by this minor version.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Fixes: 75976de6556f ("NFSD: Return word2 bitmask if setting security..,")
> [bfields: use old functions instead of new array in stable backport]
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> On Tue, May 23, 2017 at 04:38:24PM -0400, J. Bruce Fields wrote:
> > The issue is
> > 
> > 	916d2d844afd "nfsd: clean up supported attribute handling"
> > 	dcd208697707 "nfsd: fix supported attributes for acl & labels"
> > 
> > which replaced 3 numbered constants by an array, and went in between 4.8
> > and 4.10.
> > 
> > But for the purposes of older stable branches, best is probably just to
> > use the old constants.  I'll send an updated patch.
> 
> Here it is.  This should do for 4.9 and older stable branches.

Thanks, now queued up.

greg k-h
