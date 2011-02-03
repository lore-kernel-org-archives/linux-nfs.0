Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:10486 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756491Ab1BCTmD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 14:42:03 -0500
Date: Thu, 3 Feb 2011 20:41:05 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Milton Miller <miltonm@bga.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
        bfields@fieldses.org
Subject: Re: [PATCH] Fix size argument to memset call in nfsacl_encode
In-Reply-To: <1296761330.3015.22.camel@heimdal.trondhjem.org>
Message-ID: <alpine.LNX.2.00.1102032035280.15101@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net> <1296761330.3015.22.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 3 Feb 2011, Trond Myklebust wrote:

> On Thu, 2011-02-03 at 20:15 +0100, Jesper Juhl wrote: 
> > We want to give memset() the sizeof(struct posix_acl), not
> > sizeof(struct posix_acl *).
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  nfsacl.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
> > index 84c27d6..bc6d81b 100644
> > --- a/fs/nfs_common/nfsacl.c
> > +++ b/fs/nfs_common/nfsacl.c
> > @@ -117,7 +117,7 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
> >  		 * invoked in contexts where a memory allocation failure is
> >  		 * fatal.  Fortunately this fake ACL is small enough to
> >  		 * construct on the stack. */
> > -		memset(acl2, 0, sizeof(acl2));
> > +		memset(acl2, 0, sizeof(*acl2));
> >  		posix_acl_init(acl2, 4);
> >  
> >  		/* Insert entries in canonical order: other orders seem
> 
> Ccing Milton Miller who also sent in the same patch.
> 
> Neither patch is correct afaics. posix_acl_init() will clobber the above
> memset, and so the correct fix is just to get rid of it...
> 

posix_acl_init() sets a_refcount and a_count, but what about a_entries ... 
no problem, nfsacl_encode() itself takes care of that post the 
posix_acl_init() call.. it's all good.

So ...


Remove pointless memset() in nfsacl_encode().

Thanks to Trond Myklebust <Trond.Myklebust@netapp.com> for pointing out 
that it is not needed since posix_acl_init() will set everything 
regardless..

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 nfsacl.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 84c27d6..ec0f277 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -117,7 +117,6 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		 * invoked in contexts where a memory allocation failure is
 		 * fatal.  Fortunately this fake ACL is small enough to
 		 * construct on the stack. */
-		memset(acl2, 0, sizeof(acl2));
 		posix_acl_init(acl2, 4);
 
 		/* Insert entries in canonical order: other orders seem


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

