From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory
	attribute
Date: Mon, 31 Aug 2009 18:03:24 -0400
Message-ID: <20090831220324.GC5718@fieldses.org>
References: <1251746171.25048.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbZHaWDW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 18:03:22 -0400
In-Reply-To: <1251746171.25048.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 31, 2009 at 03:16:11PM -0400, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The fact that the filesystem is present does _not_ imply that the
> fs_locations attribute should be marked as "unsupported".

Yes, but the fact that the filesystem is present also does not imply
that exp->ex_fslocs.locations is NULL.  So I'm confused by your
characterization of the existing code.

If you want to do this, you probably also want to turn off the previous
exfslocs.locations check in the same function.  Otherwise we claim
support for the attribute but then never actually return it.

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfsd/nfs4xdr.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2dcc7fe..1b07183 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1825,8 +1825,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  			goto out_resource;
>  		if (!aclsupport)
>  			word0 &= ~FATTR4_WORD0_ACL;
> -		if (!exp->ex_fslocs.locations)
> -			word0 &= ~FATTR4_WORD0_FS_LOCATIONS;
>  		if (!word2) {
>  			WRITE32(2);
>  			WRITE32(word0);
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
