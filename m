Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab3IVR7U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Sep 2013 13:59:20 -0400
Date: Sun, 22 Sep 2013 19:52:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Andrey Vagin <avagin@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in
	fs/lockd/clntproc.c:131
Message-ID: <20130922175256.GA18473@redhat.com>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com> <523F22EA.2050609@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <523F22EA.2050609@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/22, Toralf Förster wrote:
>
> On 07/27/2013 07:00 PM, Oleg Nesterov wrote:
> >
> > So nlmclnt_setlockargs()->utsname() crashes and we probably need
> > the patch below.
> >
> > But is it correct? I know _absolutely_ nothing about nfs/sunrpc/etc and
> > I never looked into this code before, most probably I am wrong.
> >
> > But it seems that __nlm_async_call() relies on workqueues.
> > nlmclnt_async_call() does rpc_wait_for_completion_task(), but what if
> > the caller is killed?
> >
> > nlm_rqst can't go away, ->a_count was incremented. But can't the caller
> > exit before call->name is used? In this case the memory it points to
> > can be already freed.
> >
> > Oleg.
> >
> > --- x/kernel/exit.c
> > +++ x/kernel/exit.c
> > @@ -783,8 +783,8 @@ void do_exit(long code)
> >  	exit_shm(tsk);
> >  	exit_files(tsk);
> >  	exit_fs(tsk);
> > -	exit_task_namespaces(tsk);
> >  	exit_task_work(tsk);
> > +	exit_task_namespaces(tsk);
> >  	check_stack_usage();
> >  	exit_thread();
> >
> >
> >
> /me wonders if/when this will go in the main kernel ?

I think this was fixed by 9a1b6bf818e74 ?

Oleg.

