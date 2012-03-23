Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab2CWNmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 09:42:19 -0400
Date: Fri, 23 Mar 2012 14:34:04 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
        David Rientjes <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()
	API
Message-ID: <20120323133404.GA9095@redhat.com>
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com> <4F6B789C.8020201@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F6B789C.8020201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22, Boaz Harrosh wrote:
>
> On 03/22/2012 07:27 AM, Oleg Nesterov wrote:
> >>
> >>     usermodehelper: implement UMH_KILLABLE
> >>
> >>     Implement UMH_KILLABLE, should be used along with UMH_WAIT_EXEC/PROC.  The
> >>     caller must ensure that subprocess_info->path/etc can not go away until
> >>     call_usermodehelper_freeinfo().
> >> ...
> >>
> >> I think that my patch above does a much better/cleaner lifetime management of the
> >> subprocess_info struct, with the use of a kref.
> >
> > This is subjective, you know ;) I specially tried to avoid the
> > refcounting.
> >
>
> Why?
>
> The all kref_ abstraction comes to a simple atomic_inc/dec.

Again, this is subjective, but kref_ looks like the unnecessary
complication to me. But I won't insist, see below.

> > In any case. I do not know why do we need timeout, but this is
> > orthogonal to KILLABLE. Please redo your patches on top of -mm
> > tree? Please note that in this case the change becomes trivial.
> >
>
> Yes you are right.

OK, good.

> > Hmm. For example, exit_mm() does xchg().
> >
>
> Again, Personally I like xchg, but not here, not for an object
> life-time management. Two threads share a structure, that needs
> to go when the last one ends.

And xchg(info->complete) implements the simplest counter,
xchg() == NULL is equivalent to atomic_dec_and_test() == T.

But again, again, I won't argue if you send the patch which uses
kref_ instead. I do not maintain this code and I do not really mind.
And I never pretended my taste is good ;)

My point is, this is completely orthogonal to "add the timeout",
and if you want to change the refcounting I'd suggest a separate
patch.

What we need is wait_for_completion_state_timeout() to avoid
the horror like

	if (UMH_KILLABLE && !timeout)
		wait_for_completion_killable(...);
	else if (UMH_KILLABLE && timeout)
		wait_for_completion_killable_timeout(...);
	else if (!UMH_KILLABLE && !timeout)
		...

IOW, I think we need to export wait_for_common() first.

This is the only complication afaics. After that "add the timeout"
becomes almost one-liner, with or without "switch to kref_".


> Is there an mm git tree?

No, afaik

> random linux-next/master point. Which should do the job.

Yes, I think this should work.

Oleg.

