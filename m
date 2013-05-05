Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f54.google.com ([74.125.83.54]:47753 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab3EEJSt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 May 2013 05:18:49 -0400
Date: Sun, 5 May 2013 11:18:44 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Colin Cross <ccross@android.com>, Andrew Morton <akpm@osdl.org>,
        lkml <linux-kernel@vger.kernel.org>,
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
Message-ID: <20130505091844.GC22239@gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130505000528.GA25454@amd.pavel.ucw.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Pavel Machek <pavel@ucw.cz> wrote:

> Hi!
> 
> > >> >> --- a/kernel/exit.c
> > >> >> +++ b/kernel/exit.c
> > >> >> @@ -835,7 +835,7 @@ void do_exit(long code)
> > >> >>       /*
> > >> >>        * Make sure we are holding no locks:
> > >> >>        */
> > >> >> -     debug_check_no_locks_held(tsk);
> > >> >> +     debug_check_no_locks_held();
> > >> >
> > >> > Is task guaranteed == current?
> > >>
> > >> Yes, the first line of do_exit is:
> > >>         struct task_struct *tsk = current;
> > >
> > > Aha, I understand it now.
> > >
> > > Accessing current is slower than local variable. So your "new" code
> > > will work but will be slower. Please revert this part.
> > 
> > Using current instead of passing in tsk was done at Andrew Morton's
> > suggestion, and makes no difference from the freezer's perspective
> > since it would have to use current to get the task to pass in, so I'm
> > going to leave it as is.
> 
> Well, current is:
> 
> static inline struct thread_info *current_thread_info(void)
> {
>         register unsigned long sp asm ("sp");
>         return (struct thread_info *)(sp & ~(THREAD_SIZE - 1));
> }

That's the old 32-bit x86 trick to compute 'current' from the kernel stack 
pointer.

It can be done better - for example on platforms with optimized percpu 
variables (x86-64) it looks like this:

static inline struct thread_info *current_thread_info(void)
{
        struct thread_info *ti;
        ti = (void *)(this_cpu_read_stable(kernel_stack) +
                      KERNEL_STACK_OFFSET - THREAD_SIZE);
        return ti;
}

Which turns the computation of 'current' into a single instruction. For 
example, to access current->pid [which fields is at offset 0x2a4], we get:

    3ad0:       65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
    3ad7:       00 00
    3ad9:       8b 80 a4 02 00 00       mov    0x2a4(%rax),%eax

I also agree with the removal of the 'tsk' parameter because the function 
itself internally assumes that tsk == current.

[ We could perhaps rename the function to 
  debug_check_no_locks_held_curr(), to make it clear it operates on the 
  current task. ]

Thanks,

	Ingo
