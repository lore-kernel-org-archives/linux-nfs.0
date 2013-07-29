Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755792Ab3G2OXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jul 2013 10:23:20 -0400
Date: Mon, 29 Jul 2013 16:17:58 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
        "Serge E. Hallyn" <serge@hallyn.com>, Andrey Vagin <avagin@openvz.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in
	fs/lockd/clntproc.c:131
Message-ID: <20130729141758.GA8505@redhat.com>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com> <87iozujkdy.fsf@xmission.com> <87r4eii4td.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87r4eii4td.fsf@xmission.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/28, Eric W. Biederman wrote:
>
> > This untested patch should fix it without any need to worry about
> > dynamic behavior.

Yeees ;) I was thinking about this change too, but I have no idea
what this ->nodename actually means for nfs.

If you are going to send this patch - great!

> Although I am wondering if we have a few other spots
> > where the dynamic behavior might be iffy.

Yes. And perhaps the patch which moves exit_task_namespaces() after
exit_task_work() makes sense anyway (the patch I showed).

(but if you change nlmclnt_setlockargs() then it is not 3.11 material).

The original motivation for 8aac62706 was the leak reported by Andrey,
but that leak should be also fixed by e7b2c406. "Move exit_task_namespaces()
from exit_notify() to do_exit()" is still fine imho, the reason for
exit_task_namespaces() from the middle of exit_notify() has gone away.

But perhaps it would be better if work->func() could use ->nsproxy even
if the task is PF_EXITING.

> > Serge do you remember any of this?
> >
> > On a good day I can follow the nfs code but it takes quite a while.  I
> > feel the same way about filesystems locks so I am not really certain
> > what is going on.
> >
> > Eric
> >
> > diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> > index 9760ecb..6643cfc 100644
> > --- a/fs/lockd/clntproc.c
> > +++ b/fs/lockd/clntproc.c
> > @@ -128,11 +128,11 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
> >  
> >         nlmclnt_next_cookie(&argp->cookie);
> >         memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
> > -       lock->caller  = utsname()->nodename;
> > +       lock->caller  = init_utsname()->nodename;
> >         lock->oh.data = req->a_owner;
> >         lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
> >                                 (unsigned int)fl->fl_u.nfs_fl.owner->pid,
> > -                               utsname()->nodename);
> > +                               init_utsname()->nodename);
> >         lock->svid = fl->fl_u.nfs_fl.owner->pid;
> >         lock->fl.fl_start = fl->fl_start;
> >         lock->fl.fl_end = fl->fl_end;
> >
> > Eric  

