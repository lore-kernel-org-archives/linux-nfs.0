From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove signaling
	for shutdown
Date: Mon, 19 May 2008 16:07:12 +1000
Message-ID: <18481.6416.571430.593722@notabene.brown>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:58182 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbYESGHV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 02:07:21 -0400
In-Reply-To: message from Jeff Layton on Saturday May 17
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday May 17, jlayton@redhat.com wrote:
> knfsd is the last NFS-related kernel thread that does not use the
> kthread API. This patchset represents a first pass at converting it. It
> seems to work, but changes the shutdown interface. knfsd currently
> allows signals to tell it when to come down.
> 
> My main question is...how tied to this shutdown method are we? We can
> also take down nfsd by having people run:
> 
>      # rpc.nfsd 0
> 
> ...which basically does:
> 
>      # echo 0 > /proc/fs/nfsd/threads
> 
> ...so we don't think we *have* to use signals here. Is signaling
> something we can reasonably eliminate? 

Good question.  I suspect lots of distros still use "killall" or some
equivalent to stop nfsd - so at a minimum, some education would be
required.

Most kernel threads are there to provide a service for some other
entity, such as a filesystem or a device etc.  So it doesn't make
sense to kill them except when the device/filesystem/whatever goes
away.

With nfsd, the thread *is* the central entity.  So killing it does
make sense.
This doesn't argue strongly in favour of a killable nfsd, but does
explain why it might be different from all other kernel threads.

>                                         In addition to making the code a
> bit simpler and cleaner, I think it will also eliminate this race:
> 
>     http://lkml.org/lkml/2007/8/2/462

I never followed up on this did I...
The core problem seems to be the principle of
  "The last one out turns off the lights"
but once you've turned off the lights, you can't see if someone else
snuck back in so you aren't the last one.  You really have to have
only one door and stand in the doorway while switching off the
lights....

If we replace the BKL usage with a simple global semaphore, that
problem might just go away.  We should only need to protect
svc_destroy, svc_exit_thread, and svc_set_num_threads from each other.

It's long past time to discard the BLK here anyway.

> 
> If this isn't feasible, then I can add the signaling back in, but am not
> sure whether we can eliminate the race without adding more locking.

I think I prefer keeping the signalling and fixing the locking.

> 
> If we can do this, we may need to provide an alternate way to specify
> that we want to take down all nfsd's but not flush the export table.
> Currently that's done with a SIGHUP, but the value of this facility is
> not clear to me since the kernel can just do another upcall.

I added this functionality well before the kernel could do upcalls to
refill the export table.

I wanted to be able to change the number of active threads without a
complete shutdown and restart, so I make the /proc/fs/nfs/threads
file accessed by "nfsd NN".

Then I wanted
   nfsd 0
   nfsd 8
to just change the number of threads, not flush the exports table as
well (because at the time, flushing the exports table was more
serious).
So I arranged that "nfsd 0" just reduced the number of threads to 0
and changed no other (externally visible) state.

As you say, it isn't really needed now.   I wouldn't have a problem
with removing the SIGHUP feature, but I think keeping SIGKILL and
SIGINT with their old meaning is important.

> 
> Comments and suggestions appreciated...
> 

Thanks for the efforts!

NeilBrown
