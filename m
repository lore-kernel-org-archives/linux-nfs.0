Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab3CFSSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Mar 2013 13:18:02 -0500
Date: Wed, 6 Mar 2013 19:16:08 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306181608.GA18687@redhat.com>
References: <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com> <20130304205307.GA13527@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com> <20130305082308.6607d4db@tlielax.poochiereds.net> <20130305174648.GF12795@htj.dyndns.org> <20130305174954.GG12795@htj.dyndns.org> <20130305140312.243cb094@tlielax.poochiereds.net> <20130305190923.GI12795@htj.dyndns.org> <20130305183941.19ff39ce@tlielax.poochiereds.net> <20130305234700.GE1227@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305234700.GE1227@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05, Tejun Heo wrote:
>
> Oleg, are you still opposed to the idea of making freezer share trap
> points with ptrace?

My memory can fool me, but iirc I wasn't actually opposed... I guess
you mean the previous discussion about vfork/ptrace/etc which I forgot
completely.

But I can recall the main problem with your idea (with me): I simply
wasn't able to understand it ;)

Likewise, I can't really understand the ideas discussed in this thread.
At least when it come to this particular problem, rpc_wait_bit_killable()
is not interruptible...

And how SIGFREEZE can help? If we want to interrupt the sleeps in NFS/RPC
layer we can simply add TASK_WAKEFREEZE (can be used with TASK_KILLABLE)
and change freeze_task() to do signal_wake_up_state(TASK_WAKEFREEZE).

But if we can do this, then it should be possible so simply make these
sleeps TASK_INTERRUPTIBLE ? But it seems that we can't just because we
can't always restart, so I am totally confused.

Oleg.

