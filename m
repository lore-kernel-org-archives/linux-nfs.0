Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756007Ab3G2NPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jul 2013 09:15:50 -0400
Date: Mon, 29 Jul 2013 15:10:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrew Vagin <avagin@parallels.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
        Andrey Vagin <avagin@openvz.org>, "Serge E. Hallyn" <serue@us.ibm.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in
	fs/lockd/clntproc.c:131
Message-ID: <20130729131031.GA6157@redhat.com>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com> <51F5381D.1080904@gmx.de> <20130728175828.GA15020@redhat.com> <20130729062905.GA28282@paralelels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20130729062905.GA28282@paralelels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/29, Andrew Vagin wrote:
>
> On Sun, Jul 28, 2013 at 07:58:28PM +0200, Oleg Nesterov wrote:
> > On 07/28, Toralf Förster wrote:
> > >
> > > The attached patch works - applied on top of current git -
> > > at least the issue cannot be reproduced then.
> >
> > Thanks Toralf.
> >
> > I'll write the changelog and send the patch tomorrow.
> >
> > Andrey, any chance you can check that with this patch free_ipc_ns()
> > doesn't have any problem with ->shm_file ?
>
> kmemleak doesn't detect any leak,

Good.

> but I think this patch is incorrect.
>
> According to my previous investigations exit_task_work should be called
> after exit task namespaces
> (http://comments.gmane.org/gmane.linux.kernel/1475123)
>
> I applied the following patch:
>
> @@ -11,8 +11,11 @@ task_work_add(struct task_struct *task, struct
> callback_head *work, bool notify)
>
>         do {
>                 head = ACCESS_ONCE(task->task_works);
> -               if (unlikely(head == &work_exited))
> +               if (unlikely(head == &work_exited)) {
> +                       printk("%s:%d\n", __func__, __LINE__);
> +                       dump_stack();
>                         return -ESRCH;
> +               }
>                 work->next = head;
>         } while (cmpxchg(&task->task_works, head, work) != head);
>
>
> and I got a few backtraces in a kernel log
>
> [  151.513725] task_work_add:15
> [  151.514860] CPU: 1 PID: 15303 Comm: ipc Not tainted 3.11.0-rc2+ #75
> [  151.516743] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  151.518558]  ffff880067bf0000 ffff88006922fba0 ffffffff81630dd5 ffff88006d9b2280
> [  151.521767]  ffff88006922fbb0 ffffffff8107b478 ffff88006922fbd0 ffffffff8119ad43
> [  151.524587]  ffff880079e81740 ffff88007a9035c8 ffff88006922fbe8 ffffffff81281ebd
> [  151.527785] Call Trace:
> [  151.528811]  [<ffffffff81630dd5>] dump_stack+0x45/0x56
> [  151.530378]  [<ffffffff8107b478>] task_work_add+0x78/0x80
> [  151.533219]  [<ffffffff8119ad43>] fput+0x63/0xa0

But this is fine?

Once again, we also have e7b2c406 "fput: task_work_add() can fail if the caller
has passed exit_task_work()" commit which should also fix this particulat problem.

Before this commit - yes, we had to call exit_task_work() after exit_namespaces().

	void fput(struct file *file)
	{
		if (atomic_long_dec_and_test(&file->f_count)) {
			struct task_struct *task = current;

			file_sb_list_del(file);
			if (likely(!in_interrupt() && !(task->flags & PF_KTHREAD))) {
				init_task_work(&file->f_u.fu_rcuhead, ____fput);
				if (!task_work_add(task, &file->f_u.fu_rcuhead, true))
					return;
				/*
				 * After this task has run exit_task_work(),
				 * task_work_add() will fail.  free_ipc_ns()->
				 * shm_destroy() can do this.  Fall through to delayed
				 * fput to avoid leaking *file.
				 */
			}

			if (llist_add(&file->f_u.fu_llist, &delayed_fput_list))
				schedule_work(&delayed_fput_work);
		}
	}

Please look at the code and the comment about task_work_add().

Or I misunderstood?

Oleg.

