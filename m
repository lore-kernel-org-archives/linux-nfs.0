Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.sisk.pl ([212.160.235.94]:36440 "EHLO hydra.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713Ab3GWVdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 17:33:20 -0400
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Colin Cross <ccross@android.com>
Cc: Michael Leun <lkml20130126@newton.leun.net>,
        lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH v3 13/16] futex: use freezable blocking call)
Date: Tue, 23 Jul 2013 23:43:21 +0200
Message-ID: <1374626689.YM8vFTr171@vostro.rjw.lan>
In-Reply-To: <CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com> <20130723200854.2046296b@xenia.leun.net> <CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday, July 23, 2013 11:29:57 AM Colin Cross wrote:
> On Tue, Jul 23, 2013 at 11:08 AM, Michael Leun
> <lkml20130126@newton.leun.net> wrote:
> > On Mon, 22 Jul 2013 16:55:58 -0700
> > Colin Cross <ccross@android.com> wrote:
> >
> >> On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
> >> <lkml20130126@newton.leun.net> wrote:
> >> > On Mon,  6 May 2013 16:50:18 -0700
> >> > Colin Cross <ccross@android.com> wrote:
> >> >
> >> >> Avoid waking up every thread sleeping in a futex_wait call during
> >> > [...]
> >> >
> >> > With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> >> > displaying 0% of saving image to disk.
> >> >
> >> > echo "1" >/sys/power/state still works.
> >> >
> >> > Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4,
> >> > reverting that from 3.11-rc2 makes s2disk working again.
> >> >
> >>
> >> I think the expanded use of the freezable_* helpers is exposing an
> >> existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
> >> freeze_processes(), which sets the global system_freezing_cnt and
> >> pm_freezing.  try_to_freeze_tasks then sends every process except
> >> current a signal which causes them all to end up in the refrigerator.
> >> The current task then returns back to userspace and continues its work
> >> to suspend to disk.  If that task ever hits a call to try_to_freeze()
> >> in the kernel, it will see system_freezing_cnt and pm_freezing=true
> >> and freeze, and suspend to disk will hang forever.  It could hit
> >> try_to_freeze() because of a signal delivered to the task, or from
> >> calling any syscall that uses a freezable_* helper like the one I
> >> added to sys_futex.
> >>
> >> I think the right solution is to add a flag to the freezing task that
> >> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
> >> normally used on kernel threads, can you see if the attached patch
> >> helps?
> >
> > That patch helps.
> >
> > BTW, the only machine I can reproduce this bug with is an i7-3630QM
> > notebook. Cannot reproduce on an Core Duo U1400 and cannot reproduce on
> > an i7 M 620.
> >
> > Are the sysreq backtraces still wanted? If so, any tip, how I could get
> > them saved?
> >
> >
> > --
> > MfG,
> >
> > Michael Leun
> >
> 
> Any chance that the failing machine has threads=y in the suspend.conf file?
> 
> Rafael, it appears that swsusp's suspend.c spawns new threads after
> calling the SNAPSHOT_FREEZE ioctl.  The PF_NOFREEZE (or the new flag)
> will get copied to those new threads, but nothing will clear the flag.
>  Should I just assume that the userspace suspend code will kill those
> threads before continuing with suspend?  Or maybe add a WARN_ON in the
> kernel if any threads besides current have the new flag set when the
> suspend ops that assume all of userspace is frozen are called?

Those threads should be killed by user space.  They are only spawned for
image saving/compression/encryption and should be waited for after that.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
