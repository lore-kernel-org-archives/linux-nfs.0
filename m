Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171AbbCEPBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 10:01:39 -0500
Date: Thu, 5 Mar 2015 10:01:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150305150138.GA15674@fieldses.org>
References: <20150303224456.GV4251@dastard>
 <20150304020826.GD19439@fieldses.org>
 <20150304155421.GE1627@fieldses.org>
 <20150304220900.GX18360@dastard>
 <20150304222709.GI1627@fieldses.org>
 <20150304224557.GY4251@dastard>
 <54F78BE5.1020608@sandeen.net>
 <20150304225623.GZ4251@dastard>
 <20150305040849.GJ1627@fieldses.org>
 <20150305131731.GA16235@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150305131731.GA16235@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2015 at 02:17:31PM +0100, Christoph Hellwig wrote:
> On Wed, Mar 04, 2015 at 11:08:49PM -0500, J. Bruce Fields wrote:
> > Ah-hah:
> > 
> > 	static void
> > 	nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
> > 	{
> > 		...
> > 		nfsd4_cb_layout_fail(ls);
> > 
> > That'd do it!
> > 
> > Haven't tried to figure out why exactly that's getting called, and why
> > only rarely.  Some intermittent problem with the callback path, I guess.
> > 
> > Anyway, I think that solves most of the mystery....
> 
> Ooops, that was a nasty git merge error in the last rebase, see the fix
> below.

Thanks!

> But I really wonder if we need to make the usage of pnfs explicit
> after all, othterwise we'll always hand out layouts on any XFS-exported
> filesystems, which can't be used and will eventually need to be recalled.

Yeah, maybe.  We could check how many GETLAYOUTs we're actually seeing
on these tests.  In theory the client could quit asking, or only ask
every n seconds, if the layouts it gets are all turning out to be
useless.

--b.

> 
> ---
> >From ad592590cce9f7441c3cd21d030f3a986d8759d7 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Thu, 5 Mar 2015 06:12:29 -0700
> Subject: nfsd: don't recursively call nfsd4_cb_layout_fail
> 
> Due to a merge error when creating c5c707f9 ("nfsd: implement pNFS
> layout recalls"), we recursivelt call nfsd4_cb_layout_fail from itself,
> leading to stack overflows.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4layouts.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 3c1bfa1..1028a06 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -587,8 +587,6 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
>  
>  	rpc_ntop((struct sockaddr *)&clp->cl_addr, addr_str, sizeof(addr_str));
>  
> -	nfsd4_cb_layout_fail(ls);
> -
>  	printk(KERN_WARNING
>  		"nfsd: client %s failed to respond to layout recall. "
>  		"  Fencing..\n", addr_str);
> -- 
> 1.9.1
