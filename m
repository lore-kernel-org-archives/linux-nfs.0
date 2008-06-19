From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Thu, 19 Jun 2008 12:29:16 +1000
Message-ID: <18521.50300.572838.123366@notabene.brown>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
	<20080618210947.2110a541@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44178 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbYFSC3Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2008 22:29:24 -0400
In-Reply-To: message from Jeff Layton on Wednesday June 18
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday June 18, jlayton@redhat.com wrote:
> 
> No objection to the patch, but what signal was being sent to nfsd when
> you saw this? If it's anything but a SIGKILL, then I wonder if we have
> a race that we need to deal with. My understanding is that we have nfsd
> flip between 2 sigmasks to prevent anything but a SIGKILL from being
> delivered while we're handling the local filesystem operation.

SuSE /etc/init.d/nfsserver does

        killproc -n -KILL nfsd 

so it looks like a SIGKILL.


> 
> From nfsd():
> 
> ----------[snip]-----------
>                 sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);
> 
>                 /*
>                  * Find a socket with data available and call its
>                  * recvfrom routine.
>                  */
>                 while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
>                         ;
>                 if (err < 0)
>                         break;
>                 update_thread_usage(atomic_read(&nfsd_busy));
>                 atomic_inc(&nfsd_busy);
> 
>                 /* Lock the export hash tables for reading. */
>                 exp_readlock();
> 
>                 /* Process request with signals blocked.  */
>                 sigprocmask(SIG_SETMASK, &allowed_mask, NULL);
> 
>                 svc_process(rqstp);
> 
> ----------[snip]-----------
> 
> What happens if this catches a SIGINT after the err<0 check, but before
> the mask is set to allowed_mask? Does svc_process() then get called with
> a signal pending?

Yes, I suspect it does.

I wonder why we have all this mucking about this signal masks anyway.
Anyone have any ideas about what it actually achieves?

NeilBrown
