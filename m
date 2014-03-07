Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbaCGUUZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 15:20:25 -0500
Message-ID: <531A2A05.4040006@RedHat.com>
Date: Fri, 07 Mar 2014 15:20:21 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Stop Background mounts hang from hanging
References: <1394204563-1166-1-git-send-email-steved@redhat.com> <D803A861-E660-4D20-BDE1-00D8C45A1228@primarydata.com> <5319EA25.5060304@RedHat.com> <7DA3E2CF-F07F-448E-A907-C4BFE2B36CB4@primarydata.com> <531A1D0A.9000403@RedHat.com> <C34A5744-BD7F-4A93-9269-724B4B1A29A7@primarydata.com>
In-Reply-To: <C34A5744-BD7F-4A93-9269-724B4B1A29A7@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2014 02:45 PM, Trond Myklebust wrote:
> 
> On Mar 7, 2014, at 14:24, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Sorry... a long "lunch"... It is Friday! ;-) 
>>
>>
>> On 03/07/2014 11:10 AM, Trond Myklebust wrote:
>>>
>>> On Mar 7, 2014, at 10:47, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 03/07/2014 10:36 AM, Trond Myklebust wrote:
>>>>>
>>>>> On Mar 7, 2014, at 10:02, Steve Dickson <steved@redhat.com> wrote:
>>>>>
>>>>>> Background mounts hang forever due to the kernel not returning 
>>>>>> the time out error. The proposed fix is twofold, one in the kernel 
>>>>>> and one in the mounting code.
>>>>>>
>>>>>> The kernel patch stop the server trunking code from endlessly 
>>>>>> looping in the kernel on -ETIMEDOUT errors. Instead, the code 
>>>>>> will now return the error, allowing the mount to go into 
>>>>>> the background.
>>>>>>
>>>>>> Unfortunately, it takes over 5 mins for this timeout to 
>>>>>> happen, due the default retry strategy, which is unacceptable 
>>>>>> for background mounts. 
>>>>>>
>>>>>> So the patch I will be proposing for the mount code will be 
>>>>>> to append the "retrans=1,timeo=100" mount options to the parent
>>>>>> mount of the background mount (when they don't exist). This
>>>>>> causes the parent mount to timeout in ~25sec. 
>>>>>
>>>>> We already have a ‘retry=‘ option for mount.nfs. According to the manpage, that should be used to specify the timeout value. Why not reuse that?
>>>> Because it didn't work... retrans and timeo had most effect on the initial times set
>>>> in  nfs_init_timeout_values()
>>>>
>>>>>
>>>>> Also, it really would be better if that timeout were under control of the mount utility itself. 
>>>> Using those options, it is under the control of mount, unless I'm misunderstanding you...
>>>>
>>>>> How about if we allow the use of alarm() to interrupt that particular RPC call?
>>>> Why just use the mechanisms that already exist? Why invent a new one? Was my reasoning...
>>>
>>> alarm() is hardly a ‘new’ mechanism. It is the standard way of doing 
>>> this thing in user space, and should, in fact, already work with existing kernels, 
>>> since they allow fatal signals to interrupt all killable NFS and RPC sleeps.
>> I meant a new mechanism to the mount command... not that alarm() is a new mechanism.
>>
>>>
>>> The point is that relying on ‘retrans’ and ‘timeo’ in this context is likely to be frustrating. 
>>> ‘retrans’ and ‘timeo’ act on a per RPC call, and there are many RPC calls involved in a single 
>>> NFSv4/v4.1 mount call. 
>> Right and that's what I was thinking we needed... 
>>
>> Reading the nfs(5) man page it says "a timeout or failure causes the 
>> mount(8) command to fork a child..." The key word being "a". So we what 
>> the mount to go into background on the first timeout, which what happens 
>> when you set ‘retrans’ and ‘timeo’.
>>
>> Plus it appears v3 works that way... On the first timeout the mount command forks…
> 
> Why do we document the internals of how ‘mount’ operates? There is no reason why the user should care.
I guess I never looked at it that way... Documenting the cause and effect 
of a mount option was a good thing.. 

> 
> In fact, a much better way to achieve the exact same result entirely in user space would be simply 
> to fork immediately, set a timer, and then wait for either SIGCHLD to tell us that the 
> child is done mounting, or SIGALRM to tell us that we've timed out.
As soon as I got push back from the kernel not returning valid error... ;-) 
I thought about forking immediately and just letting the mount endlessly 
spin in the kernel... 8-)

I just don't think introducing interrupts/signals to in-flight RPCs is 
a good idea... 
 
> 
>>> Furthermore, the server may reply with something like DELAY or equivalent, 
>>> which doesn’t trigger a timeout, but keeps the kernel retrying the same RPC 
>>> call over and over again.
>>> Then there is the possibility that the hang may occur somewhere other than in the 
>>> one place you chose (for instance in the path walk). What then?
>> I was say that's a kernel bug... a timeout is a very legitimate error to return. 
> 
> We’d have to somehow let the VFS and the NFS layers know that this is a special 
> path walk that can time out. Why should we do that?
Educate me... Why in the world the VFS layer care about a network time out?

> 
>>> We can’t and we won’t add a load of stuff to the kernel to catch all the possible 
>>> sources of delay for a mount operation.
>> A "delay" is different than an timeout. A timeout is an error and a delay is not... 
>> Looping in the kernel *forever* due to a timeout error that is easily 
>> manged by the userspace, is a kernel bug... IMHO... 
>>
>> The client should not make the assumption the userspace does not
>> want to know about timeout errors. On the contrary, it *needs* to
>> know about these errors so they can do something about it...
>>
>>> That’s why if we can do it in userspace, then we should.
>> This is exactly what I want to do... Have the userspace manage 
>> timeouts... But it has to get them, to manage them.
>>
>> Using the alarm() system call bases the decision of when 
>> to fork on a arbitrary number of seconds. Using ‘retrans’ 
>> and ‘timeo’ bases that decision on an *actual* timeout
>>
>> Why interrupt a perfectly good RPC just because due
>> to an arbitrary number of seconds? Let the RPC 
>> timeout and simply report that fact….
> 
> The only difference I can see between the two is that in 
> one case, the timer is set by userland, while in the other, 
> it is set by the kernel. Again, why should a user care?
They don't and shouldn't... My point is the alarm timeout
is arbitrary... the kernel time out is because of a change 
of "state" (aka an error). I would much rather base decisions
on facts verses arbitrary guesses.. 

At the end of the day... I'll go ahead and fork immediately on 
background mounts and let the mount spin in the kernel,
but not returning timeout error, which are very manageable errors, 
is not a good thing... IMHO... 

steved.


