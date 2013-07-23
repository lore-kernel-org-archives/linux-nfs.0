Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:34123 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934136Ab3GWT36 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 15:29:58 -0400
Received: by mail-oa0-f46.google.com with SMTP id h1so12170594oag.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jul 2013 12:29:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130723211622.50f75087@xenia.leun.net>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
	<CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
	<20130723200854.2046296b@xenia.leun.net>
	<CAMbhsRT6zOKLhG_uh=nA8H_3d7afhG+4jvWjvidY3fEguryP_Q@mail.gmail.com>
	<20130723211622.50f75087@xenia.leun.net>
Date: Tue, 23 Jul 2013 12:29:57 -0700
Message-ID: <CAMbhsRQU=TswYg-2WqHmzt-_GpfMFpYHPSU4eFd5XMw7DRGXJA@mail.gmail.com>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
From: Colin Cross <ccross@android.com>
To: Michael Leun <lkml20130126@newton.leun.net>
Cc: lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 23, 2013 at 12:16 PM, Michael Leun
<lkml20130126@newton.leun.net> wrote:
> On Tue, 23 Jul 2013 11:29:57 -0700
> Colin Cross <ccross@android.com> wrote:
>
>> On Tue, Jul 23, 2013 at 11:08 AM, Michael Leun
>> <lkml20130126@newton.leun.net> wrote:
>> > On Mon, 22 Jul 2013 16:55:58 -0700
>> > Colin Cross <ccross@android.com> wrote:
>> >
>> >> On Mon, Jul 22, 2013 at 4:02 PM, Michael Leun
>> >> <lkml20130126@newton.leun.net> wrote:
>> >> > On Mon,  6 May 2013 16:50:18 -0700
>> >> > Colin Cross <ccross@android.com> wrote:
>> >> >
>> >> >> Avoid waking up every thread sleeping in a futex_wait call
>> >> >> during
>> >> > [...]
>> >> >
>> >> > With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
>> >> > displaying 0% of saving image to disk.
>> >> >
>> >> > echo "1" >/sys/power/state still works.
>> >> >
>> >> > Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4,
>> >> > reverting that from 3.11-rc2 makes s2disk working again.
>> >> >
>> >>
>> >> I think the expanded use of the freezable_* helpers is exposing an
>> >> existing bug in hibernation.  The SNAPSHOT_FREEZE ioctl calls
>> >> freeze_processes(), which sets the global system_freezing_cnt and
>> >> pm_freezing.  try_to_freeze_tasks then sends every process except
>> >> current a signal which causes them all to end up in the
>> >> refrigerator. The current task then returns back to userspace and
>> >> continues its work to suspend to disk.  If that task ever hits a
>> >> call to try_to_freeze() in the kernel, it will see
>> >> system_freezing_cnt and pm_freezing=true and freeze, and suspend
>> >> to disk will hang forever.  It could hit try_to_freeze() because
>> >> of a signal delivered to the task, or from calling any syscall
>> >> that uses a freezable_* helper like the one I added to sys_futex.
>> >>
>> >> I think the right solution is to add a flag to the freezing task
>> >> that marks it unfreezable.  I  think PF_NOFREEZE would work,
>> >> although it is normally used on kernel threads, can you see if the
>> >> attached patch helps?
>> >
>> > That patch helps.
>> >
>> > BTW, the only machine I can reproduce this bug with is an i7-3630QM
>> > notebook. Cannot reproduce on an Core Duo U1400 and cannot
>> > reproduce on an i7 M 620.
>> >
>> > Are the sysreq backtraces still wanted? If so, any tip, how I could
>> > get them saved?
>
> Darren Hart <dvhart@linux.intel.com> wrote:
>
>> Typically by setting up a serial console or a netconsole and saving
> [...]
>> Is this what you are asking?
>
> Yes, and it indeed works - I halfway expected the net / netconsole
> stuff being already frozen in that situation...
>
> Thanks, Darren - see below for the backtraces.
>
>>
>> Any chance that the failing machine has threads=y in the suspend.conf
>> file?
>
> Yes, that indeed is the trigger / difference, enabling that on the
> U4100 (its not a U1400) machine makes that fail also and disabling
> makes it work on the i7-3630QM.

Thanks, if you get a chance sysrq w might be interesting but I think
we have enough info to solve the problem.
