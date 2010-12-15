Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43136 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab0LOSiT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 13:38:19 -0500
Date: Wed, 15 Dec 2010 13:38:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101215183816.GB7773@fieldses.org>
References: <20101208212505.GA18192@hostway.ca>
 <1291845189.3067.31.camel@heimdal.trondhjem.org>
 <20101208223622.GA3796@hostway.ca>
 <1291869437.2821.6.camel@heimdal.trondhjem.org>
 <20101214233843.GB836@hostway.ca>
 <20101215011021.GA24594@hostway.ca>
 <20101215015609.GB24594@hostway.ca>
 <20101215180813.GA7773@fieldses.org>
 <1292437333.3068.14.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292437333.3068.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 01:22:13PM -0500, Trond Myklebust wrote:
> On Wed, 2010-12-15 at 13:08 -0500, J. Bruce Fields wrote:
> > On Tue, Dec 14, 2010 at 05:56:09PM -0800, Simon Kirby wrote:
> > > On Tue, Dec 14, 2010 at 05:10:21PM -0800, Simon Kirby wrote:
> > > 
> > > > On Tue, Dec 14, 2010 at 03:38:43PM -0800, Simon Kirby wrote:
> > > > 
> > > > > I'm just about to try
> > > > > 2.6.37-rc5-git3 on there plus your NFS fixes (which Linus seems to have
> > > > > half-merged and uploaded as -git3 but not pushed to his public git) 
> > > > 
> > > > Ignore this; I was just confusing myself by having the leak fixes already
> > > > applied.  Otoh, I got this Oops while trying NFSv4.  I'll check my
> > > > merging again.
> > > > 
> > > > Do you have a git branch exposed with the "Allow the admin to turn off
> > > > NFSv4 uid/gid mapping" patches applied?
> > > 
> > > Hm, the fixes were merged for -git4, and it seems to work fine there.
> > > 
> > > As for the nfs4 uid/gid mapping patch, it seems the server side support
> > > for this is still neded?
> > 
> > I'm not convinced that this behavior should depend on the security
> > flavor, so I'm assuming that something like steved's libnfsidmap patches
> > should do the job.
> 
> Don't assume.
> 
> Those patches do not fix the problem that if uid(name@server) !=
> uid(name@client), then the client will be creating files with the 'wrong
> username' on the server.

I don't see any obviously correct solution in cases where the mapping
disagrees between client and server sides, so prefer to stick to the
NFSv3 behavior.

The only reason I see to do this anyway is to provide compatibility with
NFSv3.

> In that case, everything from setuid applications through open(O_CREAT)
> to 'chown' will be broken because your authentication and authorisation
> models do not match up.

Those are preexisting problems from NFSv3, and it's up to the
administrator to fix them.

The best we can do is provide backwards-compatible behavior so that
things that worked before continue working.

--b.
