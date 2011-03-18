Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55091 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755953Ab1CRAv4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 20:51:56 -0400
Date: Fri, 18 Mar 2011 11:51:46 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Bug in xdr_copy_to_scratch???
Message-ID: <20110318115146.393119fc@notabene.brown>
In-Reply-To: <1300404473.4621.4.camel@lade.trondhjem.org>
References: <20110316213642.360be61d@notabene.brown>
	<1300282974.16266.33.camel@lade.trondhjem.org>
	<20110317093838.0f15eb98@notabene.brown>
	<1300384865.28305.27.camel@lade.trondhjem.org>
	<20110318101608.34bb1117@notabene.brown>
	<1300404139.4621.1.camel@lade.trondhjem.org>
	<1300404473.4621.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 19:27:53 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2011-03-17 at 19:22 -0400, Trond Myklebust wrote:
> > On Fri, 2011-03-18 at 10:16 +1100, NeilBrown wrote:
> > > On Thu, 17 Mar 2011 14:01:05 -0400 Trond Myklebust
> > > <Trond.Myklebust@netapp.com> wrote:
> > > 
> > > > On Thu, 2011-03-17 at 09:38 +1100, NeilBrown wrote:
> > > > > We should probably submit a fix to 2.6.37-stable though.  For that it
> > > > > is possibly simplest to tell xdr_decode_inline to round nbytes up to
> > > > > a multiple of 4 - would you agree?
> > > > 
> > > > How about the following fix for 2.6.37 stable?
> > > 
> > > That is good for NFSv3, but NFSv2 has the same problem.  Code fragment is
> > > 	p = xdr_inline_decode(xdr, entry->len + 4);
> > > 	if (unlikely(!p))
> > > 		goto out_overflow;
> > > 	entry->name	  = (const char *) p;
> > > 	p		 += XDR_QUADLEN(entry->len);
> > > 	entry->prev_cookie	  = entry->cookie;
> > > 	entry->cookie	  = ntohl(*p++);
> > > 
> > > so again we have the cookie after the name and they are decoded together.
> > 
> > Fair enough. I'll fix that one too.
> > 
> 
> Here is the result.
> 
> BTW, those are the only cases we care about in -stable. There are no
> other callers of xdr_set_scratch_buffer().

Yes, I agree.  That is a good fix - thanks.

Reviewed-by: NeilBrown <neilb@suse.de>


Thanks,
NeilBrown

> 
> 8<---------------------------------------------------------------------------------
> >From f71825a9002d4008a5b2ac947bc03b9d7c788557 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 17 Mar 2011 13:42:31 -0400
> Subject: [PATCH] NFS: Fix a decoding problem in nfs3_decode_dirent
> 
> When we decode a filename followed by an 8-byte cookie, we need to
> consider the fact that the filename and cookie are 32-bit word aligned.
> Presently, we may end up copying insufficient amounts of data when
> xdr_inline_decode() needs to invoke xdr_copy_to_scratch to deal
> with a page boundary.
> 
> The following patch fixes the issue by first decoding the filename, and
> then decoding the cookie.
> 
> Reported-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs2xdr.c |    6 ++++--
>  fs/nfs/nfs3xdr.c |    6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> index b382a1b..33a038d 100644
> --- a/fs/nfs/nfs2xdr.c
> +++ b/fs/nfs/nfs2xdr.c
> @@ -477,11 +477,13 @@ nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_se
>  	entry->ino	  = ntohl(*p++);
>  	entry->len	  = ntohl(*p++);
>  
> -	p = xdr_inline_decode(xdr, entry->len + 4);
> +	p = xdr_inline_decode(xdr, entry->len);
>  	if (unlikely(!p))
>  		goto out_overflow;
>  	entry->name	  = (const char *) p;
> -	p		 += XDR_QUADLEN(entry->len);
> +	p = xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
>  	entry->prev_cookie	  = entry->cookie;
>  	entry->cookie	  = ntohl(*p++);
>  
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index ba91236..dcd934f 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -614,11 +614,13 @@ nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_s
>  	p = xdr_decode_hyper(p, &entry->ino);
>  	entry->len  = ntohl(*p++);
>  
> -	p = xdr_inline_decode(xdr, entry->len + 8);
> +	p = xdr_inline_decode(xdr, entry->len);
>  	if (unlikely(!p))
>  		goto out_overflow;
>  	entry->name = (const char *) p;
> -	p += XDR_QUADLEN(entry->len);
> +	p = xdr_inline_decode(xdr, 8);
> +	if (unlikely(!p))
> +		goto out_overflow;
>  	entry->prev_cookie = entry->cookie;
>  	p = xdr_decode_hyper(p, &entry->cookie);
>  

