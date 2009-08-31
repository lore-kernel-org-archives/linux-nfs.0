From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory
 attribute
Date: Mon, 31 Aug 2009 19:26:05 -0400
Message-ID: <1251761165.25048.19.camel@heimdal.trondhjem.org>
References: <1251746171.25048.1.camel@heimdal.trondhjem.org>
	 <20090831220324.GC5718@fieldses.org>
	 <1251757313.25048.12.camel@heimdal.trondhjem.org>
	 <1251757790.25048.16.camel@heimdal.trondhjem.org>
	 <20090831224901.GA7466@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7145 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbZHaX1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 19:27:36 -0400
In-Reply-To: <20090831224901.GA7466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-31 at 18:49 -0400, J. Bruce Fields wrote:
> On Mon, Aug 31, 2009 at 06:29:50PM -0400, Trond Myklebust wrote:
> > On Mon, 2009-08-31 at 18:21 -0400, Trond Myklebust wrote:
> > > On Mon, 2009-08-31 at 18:03 -0400, J. Bruce Fields wrote:
> > > > If you want to do this, you probably also want to turn off the previous
> > > > exfslocs.locations check in the same function.  Otherwise we claim
> > > > support for the attribute but then never actually return it.
> > > 
> > > ...why is that a problem? Clients that conform to RFC3530 are perfectly
> > > capable of dealing with that case. The point is that if you say "I don't
> > > support this attribute", then the client will _never_ be allowed to
> > > check it.
> > 
> > Put differently: not setting the fs_locations bit in the supp_attr
> > information is equivalent to telling the client that it shouldn't ask
> > for it, and there is no time limit on that prohibition...
> 
> OK, makes sense.  There's no explicit time limit on the fs_locations
> data either, but there's at least some expectation that it could change.

Actually, if you read Dave and Carl's 2005 internet draft, you'll see
that they recommend you bump the change attribute whenever fs_locations
changes.
IOW: clients would only be allowed to cache the fs_locations information
while the change attribute remains constant.

> To me it would seem permissible, however, for a client to interpret a
> GETATTR reply which turns off a requested FS_LOCATIONS bit as stating a
> permanent lack of support for the attribute, rather than necessarily as
> stating that the list of fs_locations is currently zero-length.  So why
> not make it unambiguous and return a zero-length list?

That would work.

> With that and a corrected comment, we'd have the appended.
> 
> --b.
> 
> commit dfe14eaccdf05090b802be52ef93764387001331
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Aug 31 15:16:11 2009 -0400
> 
>     NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory attribute
>     
>     The fact that the filesystem doesn't currently list any alternate
>     locations does _not_ imply that the fs_locations attribute should be
>     marked as "unsupported".
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fdf632b..20c5e3d 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1793,11 +1793,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  				goto out_nfserr;
>  		}
>  	}
> -	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
> -		if (exp->ex_fslocs.locations == NULL) {
> -			bmval0 &= ~FATTR4_WORD0_FS_LOCATIONS;
> -		}
> -	}
>  	if ((buflen -= 16) < 0)
>  		goto out_resource;
>  
> @@ -1825,8 +1820,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  			goto out_resource;
>  		if (!aclsupport)
>  			word0 &= ~FATTR4_WORD0_ACL;
> -		if (!exp->ex_fslocs.locations)
> -			word0 &= ~FATTR4_WORD0_FS_LOCATIONS;
>  		if (!word2) {
>  			WRITE32(2);
>  			WRITE32(word0);

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
