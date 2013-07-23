Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:55642 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab3GWAmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 20:42:50 -0400
Received: by mail-oa0-f43.google.com with SMTP id i7so9776843oag.2
        for <linux-nfs@vger.kernel.org>; Mon, 22 Jul 2013 17:42:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
	<CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
	<CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com>
Date: Mon, 22 Jul 2013 17:42:49 -0700
Message-ID: <CAMbhsRReF9xB597i9CcCj7D1P5kvB4cc0JmDQYeboqi11Kp99A@mail.gmail.com>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
From: Colin Cross <ccross@android.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Leun <lkml20130126@newton.leun.net>,
        lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 22, 2013 at 5:32 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross <ccross@android.com> wrote:
>>
>> I think the right solution is to add a flag to the freezing task that
>> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
>> normally used on kernel threads, can you see if the attached patch
>> helps?
>
> Hmm. That does seem to be the right thing to do, but I wonder about
> the *other* callers of freeze_processes() IOW, kexec and friends.
>
> So maybe we should do this in {freeze|thaw}_processes() itself, and
> just make the rule be that the caller of freeze_processes() itself is
> obviously not frozen, and has to be the same one that then thaws
> things?
>
> Colin? Rafael? Comments?
>
>                 Linus

I was worried about clearing the flag in thaw_processes().  If a
kernel thread with PF_NOFREEZE set ever called thaw_processes(), which
autosleep might do, it would clear the flag.  Or if a different thread
called freeze_processes() and thaw_processes().  All the other callers
besides the SNAPSHOT_FREEZE ioctl stay in the kernel between
freeze_processes() and thaw_processes(), which makes the fanout of
places that could call try_to_freeze() much more controllable.

Using a new flag that operates like PF_NOFREEZE but doesn't conflict
with it, or a nofreeze_depth counter, would also work.
