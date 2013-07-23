Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.sisk.pl ([212.160.235.94]:33848 "EHLO hydra.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab3GWBbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 21:31:42 -0400
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Colin Cross <ccross@android.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Michael Leun <lkml20130126@newton.leun.net>,
        lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH v3 13/16] futex: use freezable blocking call)
Date: Tue, 23 Jul 2013 03:41:42 +0200
Message-ID: <15305281.aClQ8XUG9t@vostro.rjw.lan>
In-Reply-To: <CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com> <CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com> <CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday, July 22, 2013 05:42:49 PM Colin Cross wrote:
> On Mon, Jul 22, 2013 at 5:32 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross <ccross@android.com> wrote:
> >>
> >> I think the right solution is to add a flag to the freezing task that
> >> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
> >> normally used on kernel threads, can you see if the attached patch
> >> helps?
> >
> > Hmm. That does seem to be the right thing to do, but I wonder about
> > the *other* callers of freeze_processes() IOW, kexec and friends.
> >
> > So maybe we should do this in {freeze|thaw}_processes() itself, and
> > just make the rule be that the caller of freeze_processes() itself is
> > obviously not frozen, and has to be the same one that then thaws
> > things?
> >
> > Colin? Rafael? Comments?
> >
> >                 Linus
> 
> I was worried about clearing the flag in thaw_processes().  If a
> kernel thread with PF_NOFREEZE set ever called thaw_processes(), which
> autosleep might do, it would clear the flag.  Or if a different thread
> called freeze_processes() and thaw_processes().

Is that legitimate?

> All the other callers besides the SNAPSHOT_FREEZE ioctl stay in the kernel
> between freeze_processes() and thaw_processes(), which makes the fanout of
> places that could call try_to_freeze() much more controllable.
> 
> Using a new flag that operates like PF_NOFREEZE but doesn't conflict
> with it, or a nofreeze_depth counter, would also work.

Well, that would be robust enough.  At least if the purpose of that new flag
is clearly specified, people hopefully won't be tempted to optimize it away in
the future.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
