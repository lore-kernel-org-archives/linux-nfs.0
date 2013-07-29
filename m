Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:60962 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab3G2SRM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jul 2013 14:17:12 -0400
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
	<20130729141758.GA8505@redhat.com> <871u6h45zy.fsf_-_@xmission.com>
	<20130729180301.GA27148@redhat.com>
Date: Mon, 29 Jul 2013 11:17:01 -0700
In-Reply-To: <20130729180301.GA27148@redhat.com> (Oleg Nesterov's message of
	"Mon, 29 Jul 2013 20:03:01 +0200")
Message-ID: <871u6hz0wy.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131 (nfs in a netns utsns problems?)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oleg Nesterov <oleg@redhat.com> writes:

> On 07/29, Eric W. Biederman wrote:
>>
>> So I really don't think using utsname() aka current->nsproxy->uts_ns
>> makes sense in nlmclnt_setlockargs.
>>
>> We most definitely have an inconsistency in nfs.
>
> I tend to agree, but can't really comment.

If I could justify another couple of hours I could write the patch and
justify it.  I have cgroups exploding around my ears however.

>> > Yes. And perhaps the patch which moves exit_task_namespaces() after
>> > exit_task_work() makes sense anyway (the patch I showed).
>> >
>> > (but if you change nlmclnt_setlockargs() then it is not 3.11 material).
>> >
>> > The original motivation for 8aac62706 was the leak reported by Andrey,
>> > but that leak should be also fixed by e7b2c406. "Move exit_task_namespaces()
>> > from exit_notify() to do_exit()" is still fine imho, the reason for
>> > exit_task_namespaces() from the middle of exit_notify() has gone away.
>> >
>> > But perhaps it would be better if work->func() could use ->nsproxy even
>> > if the task is PF_EXITING.
>>
>> So far there is nothing in the nfs code that would suggest allowing
>> work->func() being able to use ->nsproxy would make this code any
>> better.  I think that would just paper over the problem we are seeing
>> right now.
>
> I think you misunderstood my point.
>
> I fully agree if you change nlmclnt_setlockargs(). I am suggesting to
> move exit_task_namespaces() down after exit_task_work() as a separate
> change which perhaps makes sense by itself. Not to fix this problem,
> not for nfs, not for fput().
>
> Just to allow work->func() to play with ->nsproxy if needed. task_work
> has other users, not only fput().

So to clarify I see little evidence either way on the question of should
work->funk be able to use ->nsproxy if the task is PF_EXITING.  What
little evidence I see suggests that we are actually better off not being
able to access ->nsproxy.

Eric



