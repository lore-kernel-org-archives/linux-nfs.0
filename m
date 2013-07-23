Return-Path: linux-nfs-owner@vger.kernel.org
Received: from stator.leun.net ([85.214.203.199]:39271 "EHLO stator.leun.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934008Ab3GWV7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 17:59:43 -0400
Date: Tue, 23 Jul 2013 23:58:27 +0200
From: Michael Leun <lkml20130126@newton.leun.net>
To: Colin Cross <ccross@android.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
        Linus Torvalds <torvalds@linux-foundation.org>,
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
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re:
 [PATCH v3 13/16] futex: use freezable blocking call)
Message-ID: <20130723235827.014f7899@xenia.leun.net>
In-Reply-To: <CAMbhsRSRcQ-CgCTkRGJJSVSArPqmGRjgxeRBUY0zE94Osxa-nA@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com>
	<CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
	<15305281.aClQ8XUG9t@vostro.rjw.lan>
	<CAMbhsRSsq0pgS6KvCjiFGneDEJd6zSXsYB_2MCV=sh+6F2muog@mail.gmail.com>
	<CAMbhsRSRcQ-CgCTkRGJJSVSArPqmGRjgxeRBUY0zE94Osxa-nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Jul 2013 13:31:49 -0700
Colin Cross <ccross@android.com> wrote:

> On Mon, Jul 22, 2013 at 11:28 PM, Colin Cross <ccross@android.com>
> wrote:
> > On Mon, Jul 22, 2013 at 6:41 PM, Rafael J. Wysocki <rjw@sisk.pl>
> > wrote:
> >> On Monday, July 22, 2013 05:42:49 PM Colin Cross wrote:
> >>> On Mon, Jul 22, 2013 at 5:32 PM, Linus Torvalds
> >>> <torvalds@linux-foundation.org> wrote:
> >>> > On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross
> >>> > <ccross@android.com> wrote:
> >>> >>
> >>> >> I think the right solution is to add a flag to the freezing
> >>> >> task that marks it unfreezable.  I  think PF_NOFREEZE would
> >>> >> work, although it is normally used on kernel threads, can you
> >>> >> see if the attached patch helps?
> >>> >
> >>> > Hmm. That does seem to be the right thing to do, but I wonder
> >>> > about the *other* callers of freeze_processes() IOW, kexec and
> >>> > friends.
> >>> >
> >>> > So maybe we should do this in {freeze|thaw}_processes() itself,
> >>> > and just make the rule be that the caller of freeze_processes()
> >>> > itself is obviously not frozen, and has to be the same one that
> >>> > then thaws things?
> >>> >
> >>> > Colin? Rafael? Comments?
> >>> >
> >>> >                 Linus
> >>>
> >>> I was worried about clearing the flag in thaw_processes().  If a
> >>> kernel thread with PF_NOFREEZE set ever called thaw_processes(),
> >>> which autosleep might do, it would clear the flag.  Or if a
> >>> different thread called freeze_processes() and thaw_processes().
> >>
> >> Is that legitimate?
> >
> > Nothing precludes it today, but I don't see any need for it.  I'll
> > add a comment when I add the flag.
> >
> >>> All the other callers besides the SNAPSHOT_FREEZE ioctl stay in
> >>> the kernel between freeze_processes() and thaw_processes(), which
> >>> makes the fanout of places that could call try_to_freeze() much
> >>> more controllable.
> >>>
> >>> Using a new flag that operates like PF_NOFREEZE but doesn't
> >>> conflict with it, or a nofreeze_depth counter, would also work.
> >>
> >> Well, that would be robust enough.  At least if the purpose of
> >> that new flag is clearly specified, people hopefully won't be
> >> tempted to optimize it away in the future.
> >>
> >> Thanks,
> >> Rafael
> >
> > OK, I'll add a new flag.
> 
> 
> Michael, can you see if this patch works and doesn't throw any
> warnings during suspend or resume?

Tried several times with and without threads = y in suspend.conf, tried
also to produce high load / much processes / high memory usage.

Worked every time, no WARN seen.

> If the extra process flag is considered too precious for this
> (there are only 2 left after this patch) I could get the
> same functionality by having freeze_processes() reject calls
> from a PF_KTHREAD|PF_NOFREEZE thread, and use PF_KTHREAD to
> determine if PF_NOFREEZE should be cleared in thaw_processes().

If another solution is considered please do not hesitate to send me the
patch for another round of check.

-- 
MfG,

Michael Leun

