Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:46068 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab3G2ObE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jul 2013 10:31:04 -0400
Date: Mon, 29 Jul 2013 18:27:49 +0400
From: Andrew Vagin <avagin@parallels.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Andrey Vagin <avagin@openvz.org>, "Serge E. Hallyn" <serue@us.ibm.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131
Message-ID: <20130729142749.GA27205@paralelels.com>
References: <51F39AE8.3090401@gmx.de>
 <20130727170051.GA31447@redhat.com>
 <51F5381D.1080904@gmx.de>
 <20130728175828.GA15020@redhat.com>
 <20130729062905.GA28282@paralelels.com>
 <20130729131031.GA6157@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
In-Reply-To: <20130729131031.GA6157@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 29, 2013 at 03:10:31PM +0200, Oleg Nesterov wrote:
> On 07/29, Andrew Vagin wrote:
> >
> > On Sun, Jul 28, 2013 at 07:58:28PM +0200, Oleg Nesterov wrote:
> > > On 07/28, Toralf Förster wrote:
> > > >
> > > > The attached patch works - applied on top of current git -
> > > > at least the issue cannot be reproduced then.
> > >
> > > Thanks Toralf.
> > >
> > > I'll write the changelog and send the patch tomorrow.
> > >
> > > Andrey, any chance you can check that with this patch free_ipc_ns()
> > > doesn't have any problem with ->shm_file ?
> >
> > kmemleak doesn't detect any leak,
> 
> Good.
> 
> > but I think this patch is incorrect.
> >
> > According to my previous investigations exit_task_work should be called
> > after exit task namespaces
> > (http://comments.gmane.org/gmane.linux.kernel/1475123)
> >
> > I applied the following patch:
> >
> > @@ -11,8 +11,11 @@ task_work_add(struct task_struct *task, struct
> > callback_head *work, bool notify)
> >
> >         do {
> >                 head = ACCESS_ONCE(task->task_works);
> > -               if (unlikely(head == &work_exited))
> > +               if (unlikely(head == &work_exited)) {
> > +                       printk("%s:%d\n", __func__, __LINE__);
> > +                       dump_stack();
> >                         return -ESRCH;
> > +               }
> >                 work->next = head;
> >         } while (cmpxchg(&task->task_works, head, work) != head);
> >
> >
> > and I got a few backtraces in a kernel log
> >
> > [  151.513725] task_work_add:15
> > [  151.514860] CPU: 1 PID: 15303 Comm: ipc Not tainted 3.11.0-rc2+ #75
> > [  151.516743] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  151.518558]  ffff880067bf0000 ffff88006922fba0 ffffffff81630dd5 ffff88006d9b2280
> > [  151.521767]  ffff88006922fbb0 ffffffff8107b478 ffff88006922fbd0 ffffffff8119ad43
> > [  151.524587]  ffff880079e81740 ffff88007a9035c8 ffff88006922fbe8 ffffffff81281ebd
> > [  151.527785] Call Trace:
> > [  151.528811]  [<ffffffff81630dd5>] dump_stack+0x45/0x56
> > [  151.530378]  [<ffffffff8107b478>] task_work_add+0x78/0x80
> > [  151.533219]  [<ffffffff8119ad43>] fput+0x63/0xa0
> 
> But this is fine?

Yes.

> 
> Once again, we also have e7b2c406 "fput: task_work_add() can fail if the caller
> has passed exit_task_work()" commit which should also fix this particulat problem.

Sorry, I skipped e7b2c406, which explains why I don't see leak now.
Thanks.

I don't have objections against this patch. All my tests work find.
