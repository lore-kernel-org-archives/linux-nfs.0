Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f170.google.com ([209.85.128.170]:43033 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519Ab3EDU1Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2013 16:27:24 -0400
Received: by mail-ve0-f170.google.com with SMTP id 15so2390074vea.15
        for <linux-nfs@vger.kernel.org>; Sat, 04 May 2013 13:27:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130504130440.GC13770@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<1367615050-3894-2-git-send-email-ccross@android.com>
	<20130504130440.GC13770@amd.pavel.ucw.cz>
Date: Sat, 4 May 2013 13:27:23 -0700
Message-ID: <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
From: Colin Cross <ccross@android.com>
To: Pavel Machek <pavel@ucw.cz>
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 4, 2013 at 6:04 AM, Pavel Machek <pavel@ucw.cz> wrote:
> On Fri 2013-05-03 14:04:10, Colin Cross wrote:
>> From: Mandeep Singh Baines <msb@chromium.org>
>>
>> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>> deadlock if the lock is later acquired in the suspend or hibernate path
>> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>> cgroup_freezer if a lock is held inside a frozen cgroup that is later
>> acquired by a process outside that group.
>
> Ok, but this does not explain why
>
>> --- a/include/linux/debug_locks.h
>> +++ b/include/linux/debug_locks.h
>> @@ -51,7 +51,7 @@ struct task_struct;
>>  extern void debug_show_all_locks(void);
>>  extern void debug_show_held_locks(struct task_struct *task);
>>  extern void debug_check_no_locks_freed(const void *from, unsigned long len);
>> -extern void debug_check_no_locks_held(struct task_struct *task);
>> +extern void debug_check_no_locks_held(void);
>>  #else
>>  static inline void debug_show_all_locks(void)
>>  {
>
> Removing task_struct argument from  those functions is good idea?

This is an existing patch that was merged in 3.9 and then reverted
again, so it has already been reviewed and accepted once.

>> --- a/kernel/exit.c
>> +++ b/kernel/exit.c
>> @@ -835,7 +835,7 @@ void do_exit(long code)
>>       /*
>>        * Make sure we are holding no locks:
>>        */
>> -     debug_check_no_locks_held(tsk);
>> +     debug_check_no_locks_held();
>
> Is task guaranteed == current?

Yes, the first line of do_exit is:
        struct task_struct *tsk = current;
