From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Tue, 19 Feb 2008 11:49:20 -0500
Message-ID: <20080219114920.43db6fdc@tleilax.poochiereds.net>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	<1202483596.8914.13.camel@heimdal.trondhjem.org>
	<20080208105659.3bfb8a6b@tleilax.poochiereds.net>
	<1202487187.10337.25.camel@heimdal.trondhjem.org>
	<20080212082038.7e75670e@tleilax.poochiereds.net>
	<1202861583.14707.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753081AbYBSQtj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 11:49:39 -0500
In-Reply-To: <1202861583.14707.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Feb 2008 19:13:03 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Tue, 2008-02-12 at 08:20 -0500, Jeff Layton wrote:
> > On Fri, 08 Feb 2008 11:13:07 -0500
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > 
> > > On Fri, 2008-02-08 at 10:56 -0500, Jeff Layton wrote:
> > > 
> > > > If it looks like the above, but EOF is 0, then we *do* "goto
> > > > short_pkt", and that case would be affected by this. But in that case
> > > > we currently reset EOF to 1. The client won't retry the request. I'm
> > > > not sure that's what we want to do either...
> > > 
> > > That is to deal with the afore-mentioned broken server. I'm not
> > > unwilling to change this (I _hate_ client side fixes for server bugs),
> > > but it's important to note that there may be consequences if we do.
> > 
> > Perhaps we can just narrow down this special case so that this server
> > still works, but we can return a proper error when we get other bogus
> > packets? We currently have this:
> > 
> > 	if (!nr && (entry[0] != 0 || entry[1] == 0))
> > 
> > ...but if nr==0, then I think entry[0] must be 0 as well. So, I'm
> > guessing that the server always set value_follows=0 and EOF=0. Is that
> > correct?
> > 
> > If so, what about something like the following patch? This should
> > hopefully make it so that packets that are badly sized return -EIO, but
> > the special case you mention should continue to work.
> 
> Yup. This looks like it should cover most known cases...
> 
> Cheers
>   Trond
> 

Good. I still need to test this out, but was wondering what your
thoughts are on keeping the client-side hack in place for NFSv3 and
NFSv4? Should we remove it from either or both of the later NFS
versions?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
