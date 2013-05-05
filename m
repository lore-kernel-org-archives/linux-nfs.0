Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:50824 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab3EEBNg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 21:13:36 -0400
Date: Sun, 5 May 2013 03:13:34 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Message-ID: <20130505011334.GB25454@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
 <CAMbhsRQso4fW_DVL6U3zfbX3YbLsTy8-rUA-fo61Aw93bU+sQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMbhsRQso4fW_DVL6U3zfbX3YbLsTy8-rUA-fo61Aw93bU+sQQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat 2013-05-04 17:23:01, Colin Cross wrote:
> On Sat, May 4, 2013 at 5:05 PM, Pavel Machek <pavel@ucw.cz> wrote:
> > Hi!
> >
> >> >> >> --- a/kernel/exit.c
> >> >> >> +++ b/kernel/exit.c
> >> >> >> @@ -835,7 +835,7 @@ void do_exit(long code)
> >> >> >>       /*
> >> >> >>        * Make sure we are holding no locks:
> >> >> >>        */
> >> >> >> -     debug_check_no_locks_held(tsk);
> >> >> >> +     debug_check_no_locks_held();
> >> >> >
> >> >> > Is task guaranteed == current?
> >> >>
> >> >> Yes, the first line of do_exit is:
> >> >>         struct task_struct *tsk = current;
> >> >
> >> > Aha, I understand it now.
> >> >
> >> > Accessing current is slower than local variable. So your "new" code
> >> > will work but will be slower. Please revert this part.
> >>
> >> Using current instead of passing in tsk was done at Andrew Morton's
> >> suggestion, and makes no difference from the freezer's perspective
> >> since it would have to use current to get the task to pass in, so I'm
> >> going to leave it as is.
> >
> > Well, current is:
> >
> > static inline struct thread_info *current_thread_info(void)
> > {
> >         register unsigned long sp asm ("sp");
> >         return (struct thread_info *)(sp & ~(THREAD_SIZE - 1));
> > }
> >
> > #define get_current() (current_thread_info()->task)
> >
> > #define current get_current()
> >
> > Instead of passing computed value to debug_check_no_locks_held(), you
> > force it to be computed again. do_exit() performance matters for
> > configure scripts, etc.
> >
> > I'd say it makes sense to keep the optimalization. akpm can correct
> > me.
> 
> That translates to 3 instructions, with no memory accesses:
> c0008350:       e1a0300d        mov     r3, sp
> c0008354:       e3c32d7f        bic     r2, r3, #8128   ; 0x1fc0
> c0008358:       e3c2203f        bic     r2, r2, #63     ; 0x3f

On ARM, you are right. It seems to have memory access on s390 and
x86-64. Ok, it is probably going to be in cache, but...

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
