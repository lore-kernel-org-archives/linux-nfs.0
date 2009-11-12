From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [PATCH 2/5] nfsd: Fix independence of a few nfsd
 related headers
Date: Thu, 12 Nov 2009 19:35:33 +0900
Message-ID: <1258022133.2973.5.camel@heimdal.trondhjem.org>
References: <4ADEC1EF.8040107@panasas.com>
	 <1256112873-32495-1-git-send-email-bharrosh@panasas.com>
	 <4AFBE34B.8020905@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53227 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbZKLKpn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2009 05:45:43 -0500
In-Reply-To: <4AFBE34B.8020905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-11-12 at 12:28 +0200, Boaz Harrosh wrote:
> On 10/21/2009 10:14 AM, Boaz Harrosh wrote:
> > An header should be compilation independent, .i.e pull in
> > any header who's declarations are directly used by this header.
> > And not let users re-include all it's dependencies all over
> > again.
> > 
> > [At the end of the day what's the use of a header if it does
> >  not have more then one user?]
> > 
> > Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> 
> Trond do I have an ACK on this patch.
> If not, then what should be changed to get it accepted?
> 
> > ---
> >  include/linux/nfs_xdr.h   |    1 +
> 
> This header is used exclusively by fs/nfs/... files and could just be moved
> there. The include must be fixed as below though.
> 
> >  include/linux/nfsacl.h    |    1 +
> 
> This file is used mixed between fs/nfs && fs/nfsd
> 
> >  include/linux/posix_acl.h |    1 +
> 
> Used by nfsd and filesystems
> 
> >  3 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > index 2848a26..c316ca8 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -2,6 +2,7 @@
> >  #define _LINUX_NFS_XDR_H
> >  
> >  #include <linux/nfsacl.h>
> > +#include <linux/nfs3.h>
> >  
> >  /*
> >   * To change the maximum rsize and wsize supported by the NFS client, adjust
> > diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
> > index 43011b6..f321b57 100644
> > --- a/include/linux/nfsacl.h
> > +++ b/include/linux/nfsacl.h
> > @@ -29,6 +29,7 @@
> >  #ifdef __KERNEL__
> >  
> >  #include <linux/posix_acl.h>
> > +#include <linux/sunrpc/xdr.h>
> >  
> >  /* Maximum number of ACL entries over NFS */
> >  #define NFS_ACL_MAX_ENTRIES	1024
> > diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
> > index 065a365..0dcf674 100644
> > --- a/include/linux/posix_acl.h
> > +++ b/include/linux/posix_acl.h
> > @@ -9,6 +9,7 @@
> >  #define __LINUX_POSIX_ACL_H
> >  
> >  #include <linux/slab.h>
> > +#include <linux/fs.h>

NACK to this. Pretty much _all_ filesystems already include linux/fs.h
somewhere in their include chains. There should be no need to include it
in posix_acl.h too.

> >  
> >  #define ACL_UNDEFINED_ID	(-1)
> >  
> 

So, what is the motivation for all this? We have no dependency problems
here today. What is changing in the pNFS tree that makes this so
necessary?

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
