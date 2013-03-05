Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:44852 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab3CETJ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 14:09:28 -0500
Date: Tue, 5 Mar 2013 11:09:23 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130305190923.GI12795@htj.dyndns.org>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
 <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305140312.243cb094@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Tue, Mar 05, 2013 at 02:03:12PM -0500, Jeff Layton wrote:
> Sounds intriguing...
> 
> I'm not sure what this really means for something like NFS though. How
> would you envision this working when we have long running syscalls that
> might sit waiting in the kernel indefinitely?

I think it is the same problem as being able to handle SIGKILL in
responsive manner.  It could be tricky to implement for nfs but it at
least doesn't have to solve the problem twice.

> Here's my blue-sky, poorly-thought-out idea...
> 
> We could add a signal (e.g. SIGFREEZE) that allows the sleeps in
> NFS/RPC layer to be interrupted. Those would return back toward
> userland with a particular type of error (sort of like ERESTARTSYS).
> 
> Before returning from the kernel though, we could freeze the process.
> When it wakes up, then we could go back down and retry the call again
> (much like an ERESTARTSYS kind of thing).
> 
> The tricky part here is that we'd need to distinguish between the case
> where we caught SIGFREEZE before sending an RPC vs. after. If we sent
> the call before freezing, then we don't want to resend it again. It
> might be a non-idempotent operation.

So, yeah, you are thinking pretty much the same as I'm.

> Sounds horrific to code up though... :)

I don't know the details of nfs but those events could essentially be
signaling that the system is gonna lose power.  I think it would be a
good idea to solve it.

Thanks.

-- 
tejun
