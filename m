From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/3] Intro: Better handling coarse-grained timestamps
Date: Wed, 16 Jan 2008 15:09:45 -0500 (EST)
Message-ID: <Pine.BSO.4.64.0801161505200.25972@citi.umich.edu>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
 <20080116015526.GC26010@newbie.thebellsplace.net>
 <1200449912.28088.22.camel@heimdal.trondhjem.org>
 <Pine.BSO.4.64.0801161211340.25972@citi.umich.edu>
 <1200512872.6932.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:21949 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbYAPUJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 15:09:46 -0500
In-Reply-To: <1200512872.6932.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jan 2008, Trond Myklebust wrote:
> 
> On Wed, 2008-01-16 at 12:16 -0500, david m. richter wrote:
> > 	so then, would it instead be correct to say that the negative 
> > dentry caching on the client afforded by the delegation is beneficial 
> > insofar as it obviates the client's need to revalidate the file/directory 
> > in question?  if so, i understand the flawed CTO wording and will fix the 
> > wiki.
> 
> Delegations give you a guarantee that the directory contents (i.e. the
> readdir() information) have not changed, and so the client no longer
> needs to poll the directory for change information.
> 
> IOW: specifically they allow the client to optimise away the GETATTR
> call in opendir(), and they allow it to optimise away most of
> nfs_lookup_revalidate().
> 
> Cheers
>   Trond

	good, i'm on the same page as you here.  thanks, trond,

	d
	.
