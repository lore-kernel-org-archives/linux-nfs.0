Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54931 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab0LOSWR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:22:17 -0500
Subject: Re: System CPU increasing on idle 2.6.36
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
In-Reply-To: <20101215180813.GA7773@fieldses.org>
References: <20101208212505.GA18192@hostway.ca>
	 <1291845189.3067.31.camel@heimdal.trondhjem.org>
	 <20101208223622.GA3796@hostway.ca>
	 <1291869437.2821.6.camel@heimdal.trondhjem.org>
	 <20101214233843.GB836@hostway.ca> <20101215011021.GA24594@hostway.ca>
	 <20101215015609.GB24594@hostway.ca>  <20101215180813.GA7773@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 13:22:13 -0500
Message-ID: <1292437333.3068.14.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-15 at 13:08 -0500, J. Bruce Fields wrote:
> On Tue, Dec 14, 2010 at 05:56:09PM -0800, Simon Kirby wrote:
> > On Tue, Dec 14, 2010 at 05:10:21PM -0800, Simon Kirby wrote:
> > 
> > > On Tue, Dec 14, 2010 at 03:38:43PM -0800, Simon Kirby wrote:
> > > 
> > > > I'm just about to try
> > > > 2.6.37-rc5-git3 on there plus your NFS fixes (which Linus seems to have
> > > > half-merged and uploaded as -git3 but not pushed to his public git) 
> > > 
> > > Ignore this; I was just confusing myself by having the leak fixes already
> > > applied.  Otoh, I got this Oops while trying NFSv4.  I'll check my
> > > merging again.
> > > 
> > > Do you have a git branch exposed with the "Allow the admin to turn off
> > > NFSv4 uid/gid mapping" patches applied?
> > 
> > Hm, the fixes were merged for -git4, and it seems to work fine there.
> > 
> > As for the nfs4 uid/gid mapping patch, it seems the server side support
> > for this is still neded?
> 
> I'm not convinced that this behavior should depend on the security
> flavor, so I'm assuming that something like steved's libnfsidmap patches
> should do the job.

Don't assume.

Those patches do not fix the problem that if uid(name@server) !=
uid(name@client), then the client will be creating files with the 'wrong
username' on the server.

In that case, everything from setuid applications through open(O_CREAT)
to 'chown' will be broken because your authentication and authorisation
models do not match up.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

