Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:36203 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab3EDNEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 09:04:42 -0400
Date: Sat, 4 May 2013 15:04:40 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Message-ID: <20130504130440.GC13770@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367615050-3894-2-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri 2013-05-03 14:04:10, Colin Cross wrote:
> From: Mandeep Singh Baines <msb@chromium.org>
> 
> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
> deadlock if the lock is later acquired in the suspend or hibernate path
> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
> cgroup_freezer if a lock is held inside a frozen cgroup that is later
> acquired by a process outside that group.

Ok, but this does not explain why

> --- a/include/linux/debug_locks.h
> +++ b/include/linux/debug_locks.h
> @@ -51,7 +51,7 @@ struct task_struct;
>  extern void debug_show_all_locks(void);
>  extern void debug_show_held_locks(struct task_struct *task);
>  extern void debug_check_no_locks_freed(const void *from, unsigned long len);
> -extern void debug_check_no_locks_held(struct task_struct *task);
> +extern void debug_check_no_locks_held(void);
>  #else
>  static inline void debug_show_all_locks(void)
>  {

Removing task_struct argument from  those functions is good idea?

> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -835,7 +835,7 @@ void do_exit(long code)
>  	/*
>  	 * Make sure we are holding no locks:
>  	 */
> -	debug_check_no_locks_held(tsk);
> +	debug_check_no_locks_held();

Is task guaranteed == current?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
