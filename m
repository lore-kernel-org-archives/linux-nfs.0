Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:34968 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab0HRLgV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 07:36:21 -0400
Date: Wed, 18 Aug 2010 13:36:10 +0200
From: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, stable@kernel.org
Subject: Re: 2.6.35.2: NFS related Oops
Message-ID: <20100818113610.GA27174@os.inf.tu-dresden.de>
References: <20100816215056.GA5376@os.inf.tu-dresden.de>
 <4C6A5FF1.3070209@cn.fujitsu.com>
 <20100817171454.GB11366@os.inf.tu-dresden.de>
 <1282084985.18385.24.camel@heimdal.trondhjem.org>
 <4C6B4181.50100@cn.fujitsu.com>
 <4C6B4A20.60507@cn.fujitsu.com>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <4C6B4A20.60507@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Wed Aug 18, 2010 at 10:49:04 +0800, Bian Naimeng wrote:
> >>>  	/* We can't create new files, or truncate existing ones here */
> >>>  	openflags &= ~(O_CREAT|O_TRUNC);
> >>> -- 
> >> Nope. The problem is the recent switch to LOOKUP_EXCL as the authority
> >> for whether or not we're doing an exclusive create.
> >>
> >> Does the following patch work?
> >>
> > 
> >   Hi Trond, i guess it's not work.
> > 
> >   As i see, if we want get LOOKUP_EXCL at nd->flags,  we must open file with 
> >   O_CREAT and O_EXCL, "nd->flags & LOOKUP_EXCL" have the same effect with
> >   "(openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL)", so i think the kernel
> >   still crash, right?

I can confirm, it's oopsing.

> What about this one?

This one works.

> 
>    We we open a positive file just with O_EXCL but no O_CREAT, may cause kernel crash.
> 
>   Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> ---
>  fs/namei.c   |    7 +++----
>  fs/nfs/dir.c |    2 +-
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 17ea76b..6680a38 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1813,11 +1813,10 @@ reval:
>  	nd.intent.open.create_mode = mode;
>  	nd.flags &= ~LOOKUP_PARENT;
>  	nd.flags |= LOOKUP_OPEN;
> -	if (open_flag & O_CREAT) {
> +	if (open_flag & O_CREAT)
>  		nd.flags |= LOOKUP_CREATE;
> -		if (open_flag & O_EXCL)
> -			nd.flags |= LOOKUP_EXCL;
> -	}
> +	if (open_flag & O_EXCL)
> +		nd.flags |= LOOKUP_EXCL;
>  	if (open_flag & O_DIRECTORY)
>  		nd.flags |= LOOKUP_DIRECTORY;
>  	if (!(open_flag & O_NOFOLLOW))
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 29539ce..bc25da9 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1100,7 +1100,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
>  		goto no_open_dput;
>  	openflags = nd->intent.open.flags;
>  	/* We cannot do exclusive creation on a positive dentry */
> -	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
> +	if (nd->flags & LOOKUP_EXCL)
>  		goto no_open_dput;
>  	/* We can't create new files, or truncate existing ones here */
>  	openflags &= ~(O_CREAT|O_TRUNC);
> -- 
> 1.7.0

Adam
-- 
Adam                 adam@os.inf.tu-dresden.de
  Lackorzynski         http://os.inf.tu-dresden.de/~adam/
