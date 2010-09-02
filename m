Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab0IBLvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 07:51:48 -0400
Date: Thu, 2 Sep 2010 07:55:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100902075518.58a1daf3@corrin.poochiereds.net>
In-Reply-To: <4C7F8A80.3050705@RedHat.com>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
	<20100901204818.GA10507@fieldses.org>
	<20100901165605.41f4978d@tlielax.poochiereds.net>
	<20100902073156.577757b5@notabene>
	<4C7F8A80.3050705@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 02 Sep 2010 07:29:04 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> Hey,
> 
> On 09/01/2010 05:31 PM, Neil Brown wrote:
> > 
> > Hi,
> >  I was musing about this and thought I would share my musings - not to be
> >  taken too seriously unless they resonate with you.
> > 
> >  If rpc.nfsd is mounting /proc/fs/nfsd, should it also be starting rpc.statd,
> >  which should be running before nfsd is started?
> >  Should it 'exportfs -av' too?
> > 
> >  Should mount.nfs be mounting /var/lib/nfs/rpc_pipefs too?
> >  It already runs statd as requimred, which in-turn runs sm-notify, though it
> >  is really best to run that much earlier.
> > 
> >  How far do we really want to go with this "just do the right thing" approach?
> Good point... My original thoughts were just to exit if /proc/fs/nfsd was
> not mounted, which would be the simplest way... But in the name of "things
> just working" I feel having rpc.nfsd trying the mount makes some sense... 
> 
> > 
> >  Should "rpc.nfsd" be a replacement for /etc/init.d/nfs-kernel-server or
> >  whatever your favourite distro calls it?  Or should it just be a tool for
> >  managing the nfsd threads?
> No and yes.. 
> 
> I also see rpc.nfsd becoming the real daemon which will take care of 
> all the upcalls from the kernel. Basically ripping out all the upcall code
> out of rpc.mountd and putting it into rpc.nfsd. That way rpc.mountd will
> not have to run in V4-only environments.
> 

That seems like a lot of work for little gain. rpc.nfsd (despite its
'd' suffix) is currently just a "control program". It does its thing
and then exits.

If you do the above then it'll have to live as a full-fledged daemon.
Won't we just be trading rpc.mountd for rpc.nfsd at that point? What
would be the benefit?

If you're concerned about the sockets that mountd listens on, I think
that Chuck had a patch at one point that made it possible to run mountd
as an "upcall-only" daemon for v4-only servers.

> > 
> > 
> >  I could imagine that it would be OK to add a '-L' flag to say 'use legacy
> >  interface' and have rpc.nfsd fail noisily if nfsdfs wasn't mounted, and -L
> >  wasn't given.
> > 
> >  I could imagine that if protocol options were specified with -L, that would
> >  be an error.
> Hmm... The first thing that comes to my mind is slipper slope... I think
> we just deprecate interface and move on...
> 

Agreed. Let's go ahead and start deprecating the kernel interface. We
can decide afterward what to do in userspace.

-- 
Jeff Layton <jlayton@redhat.com>
