Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:38905 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3G2BXT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jul 2013 21:23:19 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Oleg Nesterov <oleg@redhat.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        "Serge E. Hallyn" <serge@hallyn.com>, Andrey Vagin <avagin@openvz.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com>
	<87iozujkdy.fsf@xmission.com>
Date: Sun, 28 Jul 2013 17:32:30 -0700
In-Reply-To: <87iozujkdy.fsf@xmission.com> (Eric W. Biederman's message of
	"Sun, 28 Jul 2013 17:10:49 -0700")
Message-ID: <87r4eii4td.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Resending with Serge's current email address.

Eric

ebiederm@xmission.com (Eric W. Biederman) writes:

> Oleg Nesterov <oleg@redhat.com> writes:
>
>> On 07/27, Toralf Förster wrote:
>>>
>>> I do have a user mode linux image (stable 32 bit Gentoo Linux ) which erratically crashes
>>> while fuzz tested with trinity if the victim files are located on a NFS share.
>>>
>>> The back trace of the core dumps always looks like the attached.
>>>
>>> To bisect it is hard. However after few attempts in the last weeks the following
>>> commit is either the first bad commit or at least the upper limit (less likely).
>>>
>>>
>>> commit 8aac62706adaaf0fab02c4327761561c8bda9448
>>> Author: Oleg Nesterov <oleg@redhat.com>
>>> Date:   Fri Jun 14 21:09:49 2013 +0200
>>>
>>>     move exit_task_namespaces() outside of exit_notify()
>>>
>>> #15 nlmclnt_setlockargs (req=0x48e18860, fl=0x48f27c8c) at fs/lockd/clntproc.c:131
>>
>> Thanks.
>>
>> So nlmclnt_setlockargs()->utsname() crashes and we probably need
>> the patch below.
>>
>> But is it correct? I know _absolutely_ nothing about nfs/sunrpc/etc and
>> I never looked into this code before, most probably I am wrong.
>>
>> But it seems that __nlm_async_call() relies on workqueues.
>> nlmclnt_async_call() does rpc_wait_for_completion_task(), but what if
>> the caller is killed?
>>
>> nlm_rqst can't go away, ->a_count was incremented. But can't the caller
>> exit before call->name is used? In this case the memory it points to
>> can be already freed.
>
> I don't think anyone has ever looked into that.  This was a flyby
> conversion by Serge in 2006 when he originally did the uts namespace.
>
>
> from commit e9ff3990f08e9a0c2839cc22808b01732ea5b3e4
>    [PATCH] namespaces: utsname: switch to using uts namespaces
>     
>     Replace references to system_utsname to the per-process uts namespace
>     where appropriate.  This includes things like uname.
>     
>     Changes: Per Eric Biederman's comments, use the per-process uts namespace
>         for ELF_PLATFORM, sunrpc, and parts of net/ipv4/ipconfig.c
>
> Hmm.  That credits with me with this mess.  What was I thinking?
> Perhaps I just said you missed a couple of spots.
>
> This untested patch should fix it without any need to worry about
> dynamic behavior.  Although I am wondering if we have a few other spots
> where the dynamic behavior might be iffy.
>
> Serge do you remember any of this?
>
> On a good day I can follow the nfs code but it takes quite a while.  I
> feel the same way about filesystems locks so I am not really certain
> what is going on.
>
> Eric
>
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 9760ecb..6643cfc 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -128,11 +128,11 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
>  
>         nlmclnt_next_cookie(&argp->cookie);
>         memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
> -       lock->caller  = utsname()->nodename;
> +       lock->caller  = init_utsname()->nodename;
>         lock->oh.data = req->a_owner;
>         lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
>                                 (unsigned int)fl->fl_u.nfs_fl.owner->pid,
> -                               utsname()->nodename);
> +                               init_utsname()->nodename);
>         lock->svid = fl->fl_u.nfs_fl.owner->pid;
>         lock->fl.fl_start = fl->fl_start;
>         lock->fl.fl_end = fl->fl_end;
>
> Eric  
