Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:60138 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030293AbcBSJbE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Feb 2016 04:31:04 -0500
Subject: Re: call_usermodehelper in containers
To: Ian Kent <raven@themaw.net>, "Eric W. Biederman" <ebiederm@xmission.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
 <20131112004703.GB15377@kroah.com>
 <20131112061201.04cf25ab@tlielax.poochiereds.net>
 <528226EC.4050701@parallels.com>
 <20131112083043.0ab78e67@tlielax.poochiereds.net>
 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
 <20131118172844.GA10005@redhat.com> <1455149857.2903.9.camel@themaw.net>
 <8737sq4teb.fsf@x220.int.ebiederm.org> <56C53DE3.1070108@jp.fujitsu.com>
 <1455777387.3188.24.camel@themaw.net> <1455781033.2908.5.camel@themaw.net>
 <87r3g9ychc.fsf@x220.int.ebiederm.org> <56C68714.2000900@jp.fujitsu.com>
 <1455860260.3356.31.camel@themaw.net>
Cc: Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56C6E0A8.3010806@jp.fujitsu.com>
Date: Fri, 19 Feb 2016 18:30:16 +0900
MIME-Version: 1.0
In-Reply-To: <1455860260.3356.31.camel@themaw.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016/02/19 14:37, Ian Kent wrote:
> On Fri, 2016-02-19 at 12:08 +0900, Kamezawa Hiroyuki wrote:
>> On 2016/02/19 5:45, Eric W. Biederman wrote:
>>> Personally I am a fan of the don't be clever and capture a kernel
>>> thread
>>> approach as it is very easy to see you what if any exploitation
>>> opportunities there are.  The justifications for something more
>>> clever
>>> is trickier.  Of course we do something that from this perspective
>>> would
>>> be considered ``clever'' today with kthreadd and user mode helpers.
>>>
>>
>> I read old discussion....let me allow clarification  to create a
>> helper kernel thread
>> to run usermodehelper with using kthreadd.
>>
>> 0) define a trigger to create an independent usermodehelper
>> environment for a container.
>>     Option A) at creating some namespace (pid, uid, etc...)
>>     Option B) at creating a new nsproxy
>>     Option C).at a new systemcall is called or some sysctl,
>> make_private_usermode_helper() or some,
>>
>>    It's expected this should be triggered by init process of a
>> container with some capability.
>>    And scope of the effect should be defined. pid namespace ? nsporxy ?
>> or new namespace ?
>>
>> 1) create a helper thread.
>>     task = kthread_create(kthread_work_fn, ?, ?, "usermodehelper")
>>     switch task's nsproxy to current.(swtich_task_namespaces())
>>     switch task's cgroups to current (cgroup_attach_task_all())
>>     switch task's cred to current.
>>     copy task's capability from current
>>     (and any other ?)
>>     wake_up_process()
>>
>>     And create a link between kthread_wq and container.
>
> Not sure I quite understand this but I thought the difficulty with this
> approach previously (even though the approach was very much incomplete)
> was knowing that all the "moving parts" would not allow vulnerabilities.
>
Ok, that was discussed.

> And it looks like this would require a kernel thread for each instance.
> So for a thousand containers that each mount an NFS mount that means, at
> least, 1000 additional kernel threads. Might be able to sell that, if we
> were lucky, but from an system administration POV it's horrible.
>
I agree.

> There's also the question of existence (aka. lifetime) to deal with
> since the thread above needs to be created at a time other than the
> usermode helper callback.
>
> What happens for SIGKILL on a container?
>
It depends on how the helper kthread is tied to a container related object.
If kthread is linked with some namespace, we can kill it when a namespace
goes away.

So, with your opinion,
  - a helper thread should be spawned on demand
  - the lifetime of it should be clear. It will be good to have as same life time as the container.

I wonder there is no solution for "moving part" problem other than calling
do_fork() or copy_process() with container's init process context if we do all in the kernel.
Is that possible ?

Thanks,
-Kame


