Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:49078 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab3EDW5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 18:57:18 -0400
Date: Sun, 5 May 2013 00:57:15 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: lkml <linux-kernel@vger.kernel.org>,
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
        Linux PM list <linux-pm@vger.kernel.org>, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Message-ID: <20130504225715.GB24276@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat 2013-05-04 13:27:23, Colin Cross wrote:
> On Sat, May 4, 2013 at 6:04 AM, Pavel Machek <pavel@ucw.cz> wrote:
> > On Fri 2013-05-03 14:04:10, Colin Cross wrote:
> >> From: Mandeep Singh Baines <msb@chromium.org>
> >>
> >> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
> >> deadlock if the lock is later acquired in the suspend or hibernate path
> >> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
> >> cgroup_freezer if a lock is held inside a frozen cgroup that is later
> >> acquired by a process outside that group.
> >
> > Ok, but this does not explain why
> >
> >> --- a/include/linux/debug_locks.h
> >> +++ b/include/linux/debug_locks.h
> >> @@ -51,7 +51,7 @@ struct task_struct;
> >>  extern void debug_show_all_locks(void);
> >>  extern void debug_show_held_locks(struct task_struct *task);
> >>  extern void debug_check_no_locks_freed(const void *from, unsigned long len);
> >> -extern void debug_check_no_locks_held(struct task_struct *task);
> >> +extern void debug_check_no_locks_held(void);
> >>  #else
> >>  static inline void debug_show_all_locks(void)
> >>  {
> >
> > Removing task_struct argument from  those functions is good idea?
> 
> This is an existing patch that was merged in 3.9 and then reverted
> again, so it has already been reviewed and accepted once.

Well, it was also reverted once :-).

> >> --- a/kernel/exit.c
> >> +++ b/kernel/exit.c
> >> @@ -835,7 +835,7 @@ void do_exit(long code)
> >>       /*
> >>        * Make sure we are holding no locks:
> >>        */
> >> -     debug_check_no_locks_held(tsk);
> >> +     debug_check_no_locks_held();
> >
> > Is task guaranteed == current?
> 
> Yes, the first line of do_exit is:
>         struct task_struct *tsk = current;

Aha, I understand it now.

Accessing current is slower than local variable. So your "new" code
will work but will be slower. Please revert this part.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
