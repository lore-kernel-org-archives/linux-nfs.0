Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40792 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbbFIPZb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2015 11:25:31 -0400
Date: Tue, 9 Jun 2015 17:25:26 +0200
From: Petr Mladek <pmladek@suse.cz>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in
 iterant kthreads
Message-ID: <20150609152526.GB9409@pathway.suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-10-git-send-email-pmladek@suse.cz>
 <20150605161021.GJ19282@twins.programming.kicks-ass.net>
 <20150608100107.GA3135@pathway.suse.cz>
 <1433763595.1495.35.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433763595.1495.35.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 2015-06-08 13:39:55, Peter Zijlstra wrote:
> On Mon, 2015-06-08 at 12:01 +0200, Petr Mladek wrote:
> 
> > Just to be sure. Do you suggest to use TASK_IDLE everywhere in
> > kthreads or only when the uninterruptible sleep is really needed?
>
> Always, only use INTERRUPTIBLE when you're actually interruptible, that
> is you want signals or such muck to terminate your wait.

I like that TASK_IDLE clearly describes that the state of the task.
I am just curious. Is there any particular advantage of using
uninterruptible sleep over the interruptible one, please?

I ask because making freezable kthreads is quite tricky. You need to
call try_to_freeze() after each schedule or call freezable_* variants
of schedule(). I think that it is easy to make a mistake. I wonder if
it might be more elegant to use interruptible sleep whenever possible,
send the fake signal also to kthreads and force them moving into some
location where the freeze is safe and handled.


> > IMHO, we should not use TASK_IDLE in freezable kthreads because
> > it would break freezing.
> 
> How so? The task is IDLE, its not doing anything.

Well, it might cause the freeze. I have just double checked this
with ubi_thread(). It calls set_freezable().

I did the following change:

diff --git a/drivers/mtd/ubi/wl.c b/drivers/mtd/ubi/wl.c
index 16214d3d57a4..d528fa5e93ba 100644
--- a/drivers/mtd/ubi/wl.c
+++ b/drivers/mtd/ubi/wl.c
@@ -1428,7 +1428,7 @@ int ubi_thread(void *u)
                spin_lock(&ubi->wl_lock);
                if (list_empty(&ubi->works) || ubi->ro_mode ||
                    !ubi->thread_enabled || ubi_dbg_is_bgt_disabled(ubi)) {
-                       set_current_state(TASK_INTERRUPTIBLE);
+                       set_current_state(TASK_IDLE);
                        spin_unlock(&ubi->wl_lock);
                        schedule();
                        continue;


  enabled this stuff:

$> grep UBI .config
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_CUBIC=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_MTD_UBI_BLOCK=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_CRYPTO_ANUBIS is not set

  called on the running system:

$> ubiattach /dev/ubi_ctrl -m 0

  to launch "ubi_bgt0d"

  and it started to block freezer:

$> echo freezer >/sys/power/pm_test
$> echo reboot >/sys/power/disk
$> echo disk >/sys/power/state
-bash: echo: write error: Device or resource busy

$dmesg
[  658.874518] Freezing of tasks failed after 20.008 seconds (1 tasks refusing to freeze, wq_busy=0):
[  658.874527] ubi_bgt0d       D ffff880136e2be38     0  3107      2 0x00000000
[  658.874530]  ffff880136e2be38 ffff88013a456410 ffff880133808210 ffff8800b3f5cd00
[  658.874532]  ffff880136e2c000 ffff880133808210 ffff8800ba1fd15c ffff8800ba1fd1d8
[  658.874533]  ffff8800ba1fd1fc ffff880136e2be58 ffffffff81905737 ffff8800ba1fd15c
[  658.874535] Call Trace:
[  658.874540]  [<ffffffff81905737>] schedule+0x37/0x90
[  658.874543]  [<ffffffff816b3065>] ubi_thread+0xd5/0x1f0
[  658.874545]  [<ffffffff816b2f90>] ? ubi_wl_flush+0x1f0/0x1f0
[  658.874547]  [<ffffffff81085219>] kthread+0xc9/0xe0
[  658.874549]  [<ffffffff81085150>] ? kthread_create_on_node+0x180/0x180
[  658.874551]  [<ffffffff81909962>] ret_from_fork+0x42/0x70
[  658.874552]  [<ffffffff81085150>] ? kthread_create_on_node+0x180/0x180

[  658.874554] Restarting kernel threads ... done.
[  658.892995] PM: Basic memory bitmaps freed
[  658.892999] Restarting tasks ... done.


  It is because freeze_task() tries to wake up inly kthreads in
  interruptible state. I does:

		wake_up_state(p, TASK_INTERRUPTIBLE);


Solutions would be to try in freeze_task() also

		wake_up_state(p, TASK_IDLE);

or use in ubi_thread()

		freezable_schedule()

or always ignore freezing when the task sets TASK_IDLE.


> >  Well, we could freezable_schedule() but only
> > on locations where it is safe to get freezed. Anyway, we need to
> > be careful here.
> 
> Bah, you made me look at the freezer code, karma reduction for you.

I feel like it has happened.


> And this is the arch typical freeze point if ever there was one, you're
> checking kthread_stop, if we can terminate the kthread, we can certainly
> get frozen.

It makes sense. The tasks should be in some sane state when it goes
into the idle state. I hope that people will not misuse it too much.

Best Regards,
Petr
