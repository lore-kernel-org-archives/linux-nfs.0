From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Mon, 23 Jun 2008 10:20:59 +1000
Message-ID: <18526.60523.584503.68076@notabene.brown>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
	<20080618210947.2110a541@tleilax.poochiereds.net>
	<18521.50300.572838.123366@notabene.brown>
	<20080619063824.00ca6381@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755593AbYFWAVW@vger.kernel.org>
In-Reply-To: message from Jeff Layton on Thursday June 19
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday June 19, jlayton@redhat.com wrote:
> > 
> > I wonder why we have all this mucking about this signal masks anyway.
> > Anyone have any ideas about what it actually achieves?
> > 
> 
> HCH asked me the same question when I did the conversion to kthreads.
> My interpretation (based on guesswork here) was that we wanted to
> distinguish between SIGKILL and other allowed signals. A SIGKILL is
> allowed to interrupt the underlying I/O, but other signals should not.

Yes, that seems to be the intent of the code, but does it really make
any sense?
Traditionally, filesystem IO is immune to signals so any signal
arriving while nfsd is doing filesystem IO is irrelevant.
I guess network IO can be interrupted, and nfsd is expected to write
to the network during this time when all-but-SIGKILL is ignored.  So
maybe the intent was to allow e.g. SIGINT to shut down cleanly, and
SIGKILL to kill more promptly even if the network was sluggish...

However I don't think we ever blocked on network write.  And currently
we try very hard to ensure that there is enough memory to hold a reply
before we start on a request, so it should definitely never block.

So until OCFS2 came along, the distinction seems to have been
meaningless, which is why I questioned it.

Even with OCFS2 I'm not sure it makes much sense.

Any time that we shut down NFSD, we really want it to shut down
promptly.  If SIGINT isn't certain to achieve that, we should just be
sending SIGKILL.
Conversely, if it does make sense to keep the two signals, we should
be educating init.d scripts to make use of them. e.g.

  killall -2 nfsd
  sleep 0.1
  if [ `cat /proc/fs/nfsd/threads` -gt 0 ]
  then sleep 5
       killall -9 nfsd
  fi

or something more clever.

I think my leaning is just to remove the distinction.  About the worst
that can happen if the filesystem decides to respond to the signal is
that you get a short write or a short read, both of which should be
correctly handled by the client.


This brings up an interesting issue for your kthread conversion.
The new code uses kthread_stop instead of sending a signal.  That
means it will block until the threads have completed a request and
exited.
If some thread is in a filesystem that is waiting on network IO and
expects to get a signal if it needs to stop in a hurry, then the
shutdown could block for a long time.  That might not be what we
want.

Particularly as if we are blocked in kthread_stop, then no-one else can
do a kthread stop....

I think there are issues here that don't yet have obvious answers.
Other opinions most welcome.


> 
> The question to answer here, I suppose, is whether masking a pending
> signal is sufficient to make signal_pending() return false. If I'm
> looking correctly then the answer should be "yes". So I don't think we
> have a race here after all. I suspect that if SuSE used a different
> signal here, that would prevent this from happening. For the record,
> both RHEL and Fedora's init scripts use SIGINT for this.

Yep.  Using SIGINT or "rpc.nfsd 0" would avoid the problem.
So does mounted the OCFS2 filesystem with -o nointr.

NeilBrown
