Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab1BNWXE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 17:23:04 -0500
Subject: Re: [PATCH] NFS: Zap entire 'struct inode' in
 nfs_zap_caches_locked().
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <alpine.LNX.2.00.1102142311330.4530@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102142252540.4530@swampdragon.chaosbits.net>
	 <1297721385.23841.14.camel@heimdal.trondhjem.org>
	 <alpine.LNX.2.00.1102142311330.4530@swampdragon.chaosbits.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Feb 2011 17:23:02 -0500
Message-ID: <1297722182.23841.21.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-14 at 23:12 +0100, Jesper Juhl wrote: 
> On Mon, 14 Feb 2011, Trond Myklebust wrote:
> 
> > On Mon, 2011-02-14 at 22:56 +0100, Jesper Juhl wrote: 
> > > nfs_zap_caches_locked() attempts to zero all of the 'struct inode' that's 
> > > passed in via the pointer variable 'inode'. Unfortunately it only manages 
> > > to zero the size of a 'pointer to struct inode'. Fix that.
> > > 
> > > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > > ---
> > >  inode.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > >  compile tested only
> > > 
> > > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > > index 1cc600e..6c4236e 100644
> > > --- a/fs/nfs/inode.c
> > > +++ b/fs/nfs/inode.c
> > > @@ -145,7 +145,7 @@ static void nfs_zap_caches_locked(struct inode *inode)
> > >  	nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
> > >  	nfsi->attrtimeo_timestamp = jiffies;
> > >  
> > > -	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
> > > +	memset(NFS_COOKIEVERF(inode), 0, sizeof(*NFS_COOKIEVERF(inode)));
> > >  	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
> > >  		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
> > >  	else
> > 
> > That's incorrect.
> > 
> > NFS_COOKIEVERF(inode) expands to NFS_I(inode)->cookieverf, and since
> > cookieverf is declared inside the struct nfs_inode as 
> > 
> > 	u32	cookieverf[2];
> > 
> > the sizeof(NFS_I(inode)->cookieverf) should expand to the size of the
> > cookieverf array (i.e. 8 bytes).
> > 
> Ouch, I completely misread/misunderstood that. Thanks for the 
> clarification and please ignore the patch...

No problem. I can see how the NFS_COOKIEVERF() macro can be confusing. I
should post a patch to get rid of that macro for 2.6.39 and just open
code the few instances that care about accessing the cookieverf field.

Other macros that have outlived their usefulness include NFS_FH(),
NFS_FILEID(), NFS_CLIENT() and possibly NFS_SERVER()...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

