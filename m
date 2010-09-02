Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752319Ab0IBL3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 07:29:14 -0400
Message-ID: <4C7F8A80.3050705@RedHat.com>
Date: Thu, 02 Sep 2010 07:29:04 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
CC: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>	<20100901204818.GA10507@fieldses.org>	<20100901165605.41f4978d@tlielax.poochiereds.net> <20100902073156.577757b5@notabene>
In-Reply-To: <20100902073156.577757b5@notabene>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey,

On 09/01/2010 05:31 PM, Neil Brown wrote:
> 
> Hi,
>  I was musing about this and thought I would share my musings - not to be
>  taken too seriously unless they resonate with you.
> 
>  If rpc.nfsd is mounting /proc/fs/nfsd, should it also be starting rpc.statd,
>  which should be running before nfsd is started?
>  Should it 'exportfs -av' too?
> 
>  Should mount.nfs be mounting /var/lib/nfs/rpc_pipefs too?
>  It already runs statd as requimred, which in-turn runs sm-notify, though it
>  is really best to run that much earlier.
> 
>  How far do we really want to go with this "just do the right thing" approach?
Good point... My original thoughts were just to exit if /proc/fs/nfsd was
not mounted, which would be the simplest way... But in the name of "things
just working" I feel having rpc.nfsd trying the mount makes some sense... 

> 
>  Should "rpc.nfsd" be a replacement for /etc/init.d/nfs-kernel-server or
>  whatever your favourite distro calls it?  Or should it just be a tool for
>  managing the nfsd threads?
No and yes.. 

I also see rpc.nfsd becoming the real daemon which will take care of 
all the upcalls from the kernel. Basically ripping out all the upcall code
out of rpc.mountd and putting it into rpc.nfsd. That way rpc.mountd will
not have to run in V4-only environments.

> 
> 
>  I could imagine that it would be OK to add a '-L' flag to say 'use legacy
>  interface' and have rpc.nfsd fail noisily if nfsdfs wasn't mounted, and -L
>  wasn't given.
> 
>  I could imagine that if protocol options were specified with -L, that would
>  be an error.
Hmm... The first thing that comes to my mind is slipper slope... I think
we just deprecate interface and move on...

> 
>  And if protocol options are specified which differ from what is currently
>  in-force, and there are active threads, rpc.nfsd could:
>     reduce the number of threads to 0
>     change the protocol options
>     restore the number of threads
> 
> 
> 
>  I think it is (long past) time to deprecate the legacy support in the kernel
>  at least.  I suggest we add a printk to sys_nfsservctl to warn of pending
>  deprecation, and probably add an entry to
>  Documentation/feature-removal-schedule.txt.
>  Aim for removing it all in 2.6.40 ?? and make it a CONFIG option before that.
I second this...

> 
>  BTW, the 'new' cache has was added during 2.5 - definitely before Jan 2003.
>  So the old stuff really is quite old now.
Wow... it is time...

steved.
