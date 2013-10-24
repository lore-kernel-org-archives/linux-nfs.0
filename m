Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573Ab3JXPXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 11:23:24 -0400
Date: Thu, 24 Oct 2013 11:23:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Message-ID: <20131024112319.7ad9fd27@tlielax.poochiereds.net>
In-Reply-To: <1382627770.899.79.camel@willson.li.ssimo.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	<EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	<1382624000.6907.8.camel@heisenberg.scientia.net>
	<E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
	<1382627225.899.76.camel@willson.li.ssimo.org>
	<1382627496.6430.2.camel@leira.trondhjem.org>
	<1382627770.899.79.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 24 Oct 2013 11:16:10 -0400
Simo Sorce <simo@redhat.com> wrote:

> On Thu, 2013-10-24 at 15:11 +0000, Myklebust, Trond wrote:
> > On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:
> > 
> > > Because the filesystem can do that when multiple applications are
> > > involved without having to change them all to talk to each other and
> > > invent custom protocol all the time just to keep some additional
> > > metadata associated to a file..
> > > 
> > It's still a custom protocol. The applications need to agree on a data
> > format and store it somewhere. The portable way to do this is to write
> > an application library that they can link to.
> 
> Perhaps I was unclear, you are never going to see that custom library
> linked into the 'mv' command.
> 
> So your approach makes little sense if the object is to maintain data
> coherent when people need to handle files from random applications and
> scripts and general system maintenance.
> 
> The data may be relevant only to a specific application.
> 
> I am not saying you *have* to implement xattrs support, just saying that
> it is not a mere 'applications should synchronize data themselves'
> problem.
> 

I think the real solution if people need this is to lead an effort to
put xattrs into the spec. I think there is still time to get new
features into v4.3 if someone wants to champion it...

-- 
Jeff Layton <jlayton@redhat.com>
