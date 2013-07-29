Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out01.mta.xmission.com ([166.70.13.231]:44848 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab3G2RnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jul 2013 13:43:15 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Oleg Nesterov <oleg@redhat.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        "Serge E. Hallyn" <serge@hallyn.com>, Andrey Vagin <avagin@openvz.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com>
	<87iozujkdy.fsf@xmission.com> <87r4eii4td.fsf@xmission.com>
	<20130729141758.GA8505@redhat.com>
Date: Mon, 29 Jul 2013 10:42:57 -0700
In-Reply-To: <20130729141758.GA8505@redhat.com> (Oleg Nesterov's message of
	"Mon, 29 Jul 2013 16:17:58 +0200")
Message-ID: <871u6h45zy.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131 (nfs in a netns utsns problems?)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Adding some people who pay more attention to nfs in network namespaces
than I usually do.

Oleg Nesterov <oleg@redhat.com> writes:

> On 07/28, Eric W. Biederman wrote:
>>
>> > This untested patch should fix it without any need to worry about
>> > dynamic behavior.
>
> Yeees ;) I was thinking about this change too, but I have no idea
> what this ->nodename actually means for nfs.
>
> If you are going to send this patch - great!

Just batting it around for now, and hoping we have the right combination
of eyeballs look at it.  There are more places in nfs that have
questionable uses of utsname() instead of init_utsname().  So I think we
probably need a more comprehensive patch at the very least.

nfsclnt_reclaim is never called from userspace.
nfsclnt_cancel is called from a callback that seems to have no guarantee
                 of an approprate userspace context.
nfsclnt_proc is called from rpc_ops and I did not spend the time to see
             if that could be a userspace context.

So I really don't think using utsname() aka current->nsproxy->uts_ns
makes sense in nlmclnt_setlockargs.

We most definitely have an inconsistency in nfs.  I am a little hesitant
to suggest my patch because it is likely to have strange effects on nfs
in a network namespace.  On the flip side the code is broken anyway, we
might as well at least use a version that is guarnateed not to cause
a null pointer dereference in the kernel.

This is the first time someone has seen a problem since late 2006 since
Serge updated most of the references to use system_utsname but I think
we have just been lucky.

>> Although I am wondering if we have a few other spots
>> > where the dynamic behavior might be iffy.
>
> Yes. And perhaps the patch which moves exit_task_namespaces() after
> exit_task_work() makes sense anyway (the patch I showed).
>
> (but if you change nlmclnt_setlockargs() then it is not 3.11 material).
>
> The original motivation for 8aac62706 was the leak reported by Andrey,
> but that leak should be also fixed by e7b2c406. "Move exit_task_namespaces()
> from exit_notify() to do_exit()" is still fine imho, the reason for
> exit_task_namespaces() from the middle of exit_notify() has gone away.
>
> But perhaps it would be better if work->func() could use ->nsproxy even
> if the task is PF_EXITING.

So far there is nothing in the nfs code that would suggest allowing
work->func() being able to use ->nsproxy would make this code any
better.  I think that would just paper over the problem we are seeing
right now.

>> > Serge do you remember any of this?
>> >
>> > On a good day I can follow the nfs code but it takes quite a while.  I
>> > feel the same way about filesystems locks so I am not really certain
>> > what is going on.
>> >
>> > Eric
>> >
>> > diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>> > index 9760ecb..6643cfc 100644
>> > --- a/fs/lockd/clntproc.c
>> > +++ b/fs/lockd/clntproc.c
>> > @@ -128,11 +128,11 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
>> >  
>> >         nlmclnt_next_cookie(&argp->cookie);
>> >         memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
>> > -       lock->caller  = utsname()->nodename;
>> > +       lock->caller  = init_utsname()->nodename;
>> >         lock->oh.data = req->a_owner;
>> >         lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
>> >                                 (unsigned int)fl->fl_u.nfs_fl.owner->pid,
>> > -                               utsname()->nodename);
>> > +                               init_utsname()->nodename);
>> >         lock->svid = fl->fl_u.nfs_fl.owner->pid;
>> >         lock->fl.fl_start = fl->fl_start;
>> >         lock->fl.fl_end = fl->fl_end;
>> >
>> > Eric  
