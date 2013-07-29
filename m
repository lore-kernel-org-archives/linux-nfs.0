Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:44491 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab3G2GcH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jul 2013 02:32:07 -0400
Date: Mon, 29 Jul 2013 10:29:06 +0400
From: Andrew Vagin <avagin@parallels.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Andrey Vagin <avagin@openvz.org>, "Serge E. Hallyn" <serue@us.ibm.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131
Message-ID: <20130729062905.GA28282@paralelels.com>
References: <51F39AE8.3090401@gmx.de>
 <20130727170051.GA31447@redhat.com>
 <51F5381D.1080904@gmx.de>
 <20130728175828.GA15020@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
In-Reply-To: <20130728175828.GA15020@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 28, 2013 at 07:58:28PM +0200, Oleg Nesterov wrote:
> On 07/28, Toralf Förster wrote:
> >
> > The attached patch works - applied on top of current git -
> > at least the issue cannot be reproduced then.
> 
> Thanks Toralf.
> 
> I'll write the changelog and send the patch tomorrow.
> 
> Andrey, any chance you can check that with this patch free_ipc_ns()
> doesn't have any problem with ->shm_file ?

kmemleak doesn't detect any leak, but I think this patch is incorrect.

According to my previous investigations exit_task_work should be called
after exit task namespaces
(http://comments.gmane.org/gmane.linux.kernel/1475123)

I applied the following patch:

@@ -11,8 +11,11 @@ task_work_add(struct task_struct *task, struct
callback_head *work, bool notify)
 
        do {
                head = ACCESS_ONCE(task->task_works);
-               if (unlikely(head == &work_exited))
+               if (unlikely(head == &work_exited)) {
+                       printk("%s:%d\n", __func__, __LINE__);
+                       dump_stack();
                        return -ESRCH;
+               }
                work->next = head;
        } while (cmpxchg(&task->task_works, head, work) != head);
 

and I got a few backtraces in a kernel log

[  151.513725] task_work_add:15
[  151.514860] CPU: 1 PID: 15303 Comm: ipc Not tainted 3.11.0-rc2+ #75
[  151.516743] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  151.518558]  ffff880067bf0000 ffff88006922fba0 ffffffff81630dd5 ffff88006d9b2280
[  151.521767]  ffff88006922fbb0 ffffffff8107b478 ffff88006922fbd0 ffffffff8119ad43
[  151.524587]  ffff880079e81740 ffff88007a9035c8 ffff88006922fbe8 ffffffff81281ebd
[  151.527785] Call Trace:
[  151.528811]  [<ffffffff81630dd5>] dump_stack+0x45/0x56
[  151.530378]  [<ffffffff8107b478>] task_work_add+0x78/0x80
[  151.533219]  [<ffffffff8119ad43>] fput+0x63/0xa0
[  151.534884]  [<ffffffff81281ebd>] shm_destroy+0x7d/0xb0
[  151.536813]  [<ffffffff81281f05>] do_shm_rmid+0x15/0x50
[  151.539523]  [<ffffffff81286572>] free_ipcs+0xa2/0xf0
[  151.541595]  [<ffffffff81286534>] ? free_ipcs+0x64/0xf0
[  151.544188]  [<ffffffff81281ef0>] ? shm_destroy+0xb0/0xb0
[  151.546393]  [<ffffffff81282990>] shm_exit_ns+0x20/0x30
[  151.548675]  [<ffffffff81286619>] put_ipc_ns+0x59/0x80
[  151.552764]  [<ffffffff81083afd>] free_nsproxy+0x3d/0x90
[  151.560241]  [<ffffffff81083d45>] switch_task_namespaces+0x45/0x50
[  151.564211]  [<ffffffff81083d60>] exit_task_namespaces+0x10/0x20
[  151.566097]  [<ffffffff8105d3fd>] do_exit+0x2ad/0xa20
[  151.567744]  [<ffffffff81307ec1>] ? do_raw_spin_lock+0x41/0x110
[  151.570734]  [<ffffffff8163965c>] ? _raw_spin_unlock_irq+0x2c/0x40
[  151.573967]  [<ffffffff8105dbf9>] do_group_exit+0x49/0xc0
[  151.576773]  [<ffffffff8106d593>] get_signal_to_deliver+0x293/0x640
[  151.580575]  [<ffffffff81002458>] do_signal+0x48/0x5a0
[  151.582401]  [<ffffffff811b83f6>] ? mntput_no_expire+0xd6/0x120
[  151.584418]  [<ffffffff8163a41e>] ? paranoid_userspace+0x39/0x5a
[  151.588639]  [<ffffffff810bc42d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
[  151.590809]  [<ffffffff81002a18>] do_notify_resume+0x68/0x90
[  151.604976]  [<ffffffff8163a430>] paranoid_userspace+0x4b/0x5a


Thanks,
Andrey

> 
> e7b2c406 should be enough to fix that leak, but it would be nice if
> you can confirm.
> 
> > On 07/27/2013 07:00 PM, Oleg Nesterov wrote:
> > > On 07/27, Toralf Förster wrote:
> > >>
> > >> I do have a user mode linux image (stable 32 bit Gentoo Linux ) which erratically crashes
> > >> while fuzz tested with trinity if the victim files are located on a NFS share.
> > >>
> > >> The back trace of the core dumps always looks like the attached.
> > >>
> > >> To bisect it is hard. However after few attempts in the last weeks the following
> > >> commit is either the first bad commit or at least the upper limit (less likely).
> > >>
> > >>
> > >> commit 8aac62706adaaf0fab02c4327761561c8bda9448
> > >> Author: Oleg Nesterov <oleg@redhat.com>
> > >> Date:   Fri Jun 14 21:09:49 2013 +0200
> > >>
> > >>     move exit_task_namespaces() outside of exit_notify()
> > >>
> > >> #15 nlmclnt_setlockargs (req=0x48e18860, fl=0x48f27c8c) at fs/lockd/clntproc.c:131
> > > 
> > > Thanks.
> > > 
> > > So nlmclnt_setlockargs()->utsname() crashes and we probably need
> > > the patch below.
> > > 
> > > But is it correct? I know _absolutely_ nothing about nfs/sunrpc/etc and
> > > I never looked into this code before, most probably I am wrong.
> > > 
> > > But it seems that __nlm_async_call() relies on workqueues.
> > > nlmclnt_async_call() does rpc_wait_for_completion_task(), but what if
> > > the caller is killed?
> > > 
> > > nlm_rqst can't go away, ->a_count was incremented. But can't the caller
> > > exit before call->name is used? In this case the memory it points to
> > > can be already freed.
> > > 
> > > Oleg.
> > > 
> > > --- x/kernel/exit.c
> > > +++ x/kernel/exit.c
> > > @@ -783,8 +783,8 @@ void do_exit(long code)
> > >  	exit_shm(tsk);
> > >  	exit_files(tsk);
> > >  	exit_fs(tsk);
> > > -	exit_task_namespaces(tsk);
> > >  	exit_task_work(tsk);
> > > +	exit_task_namespaces(tsk);
> > >  	check_stack_usage();
> > >  	exit_thread();
> > >  
> > > 
> > > 
> > 
> > 
> > -- 
> > MfG/Sincerely
> > Toralf Förster
> > pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
> 
