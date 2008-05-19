From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove	signaling
 for shutdown
Date: Mon, 19 May 2008 15:00:00 -0700
Message-ID: <4831F860.6050801@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com> <18481.6416.571430.593722@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:40051 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764815AbYESWC2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 18:02:28 -0400
In-Reply-To: <18481.6416.571430.593722-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Saturday May 17, jlayton@redhat.com wrote:
>   
>
> With nfsd, the thread *is* the central entity.  So killing it does
> make sense.
> This doesn't argue strongly in favour of a killable nfsd, but does
> explain why it might be different from all other kernel threads.
>   
There's also the unique history of nfsd, that it was historically a
userspace daemon, so that "killall nfsd" was once the only method of
shutting down nfsds.  Arguably we need to preserve that semantic to
avoid breaking distros.

Unfortunately, it's a horrible and racy semantic.  At least on SLES10,
the /etc/init.d/ script that performs graceful shutdowns of the NFS
server will do "killall nfsd" and then, without checking to see whether
all the nfsds have actually died, proceeds to run the script that shuts
down the portmapper.  If the nfsd are a long time dying, e.g. due to
some slow filesystem work or if you just have a very large number of
nfsds, the last nfsd will try to unregister program 100003 with the the
portmapper after the portmapper is down.  This will leave a single nfsd
alive, failing and retrying for a total of hundreds of seconds.  During
that time, you can't restart the NFS service.

So while "killall nfsd" needs to continue to work, a additional smarter
mechanism would be great also.

>
> If we replace the BKL usage with a simple global semaphore, that
> problem might just go away.  We should only need to protect
> svc_destroy, svc_exit_thread, and svc_set_num_threads from each other.
>   
I think we also need to protect those against svc_create_pooled(). I
tried this a few weeks back in an attempt to deal with a customer's
problem, but gave up in disgust when the obvious changes resulted in the
nfsds self-deadlocking during startup.  The svc_serv was being created
as a side effect of the first write to a /proc/fs/nfsd/ file, and the
locking was very very confused.  I think it would be great if you gave
that code some care and attention.
> It's long past time to discard the BLK here anyway.
>   
Very true!
>   
>> If this isn't feasible, then I can add the signaling back in, but am not
>> sure whether we can eliminate the race without adding more locking.
>>     
>
> I think I prefer keeping the signalling and fixing the locking.
>   
I agree.
>   
>> Comments and suggestions appreciated...
>>
>>     
>
>   
Thanks for doing this :-)  I'll send out the patch I mentioned when we
chatted at Cthon, maybe you can consider the issue it fixes.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

