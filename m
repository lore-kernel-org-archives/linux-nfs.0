Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab0IBARl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 20:17:41 -0400
Date: Wed, 1 Sep 2010 20:17:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100901201730.1a7b2635@tlielax.poochiereds.net>
In-Reply-To: <20100902073156.577757b5@notabene>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
	<20100901204818.GA10507@fieldses.org>
	<20100901165605.41f4978d@tlielax.poochiereds.net>
	<20100902073156.577757b5@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2 Sep 2010 07:31:56 +1000
Neil Brown <neilb@suse.de> wrote:

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
> 
>  Should "rpc.nfsd" be a replacement for /etc/init.d/nfs-kernel-server or
>  whatever your favourite distro calls it?  Or should it just be a tool for
>  managing the nfsd threads?
> 

That's the way I envision it. rpc.nfsd is a tool for managing the nfsd
threads, and the protocol versions and sockets that they use.

Personally I see a clear delineation here. It's ok for rpc.nfsd to
mount up /proc/fs/nfsd since it needs that interface to properly do its
job. Doing things like starting statd or mounting up pipefs are outside
of its scope.

It just seems a little weird to me that we ought to mandate that
someone run "modprobe nfsd" or whatever before they can actually do
anything with rpc.nfsd.

> 
>  I could imagine that it would be OK to add a '-L' flag to say 'use legacy
>  interface' and have rpc.nfsd fail noisily if nfsdfs wasn't mounted, and -L
>  wasn't given.
> 
>  I could imagine that if protocol options were specified with -L, that would
>  be an error.
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
> 
>  BTW, the 'new' cache has was added during 2.5 - definitely before Jan 2003.
>  So the old stuff really is quite old now.
> 

Deprecating it in kernel via your plan sounds good to me.

Failing noisily if /proc/fs/nfsd isn't mounted was what Steve was
suggesting. What would be the benefit there of not attempting to mount
nfsdfs first?

It would certainly be simpler, but is it likely to lead to any harm? If
not, it seems like a reasonable way to limit user confusion. It's hard
to understate the value of having it "just work".

The '-L' flag was sort of what I was thinking might be a good long
term plan, though I was leaning toward a compile-time switch. For
instance, "./configure --with-legacy-nfsd-interface".

We could continue to support nfsctl() for a period of time in mainline
nfs-utils via that switch. The actual mechanics of how to do that would
need to be worked out though.

-- 
Jeff Layton <jlayton@redhat.com>
