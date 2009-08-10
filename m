Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35905 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbZHJULO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2009 16:11:14 -0400
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Message-Id: <C7F6C388-5436-424D-8D5A-72E2DD24C7C0@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
In-Reply-To: <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; delsp=yes
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Mon, 10 Aug 2009 16:11:04 -0400
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com> <f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com> <4A7BCCCA.4020307@panasas.com> <20090807140425.GA18298@fieldses.org> <f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com> <A411E867-D130-4D82-89F0-5C73077EE475@oracle.com> <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug 10, 2009, at 3:43 PM, Carlos André wrote:
> No, i'm just using packages from CentOS repo...
>
> And u're right about expo retries... with tcpdump i've monitored
> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
> 2049...
> I tried use "retry=1" option on mount without any change...

That won't have any effect on the kernel's TCP connect behavior.  It  
is simply used by the mount command to know when to stop redriving  
mount(2) system calls.  The current mount command doesn't actually  
interrupt the mount(2) system call if it's taking longer than the  
specified "retry=" setting.

> I don't want change source or tcp timers... just NFSv4 client.

I don't know of any way to effect a change in the kernel's TCP connect  
behavior short of a code change, and that would affect all RPC/TCP  
programs.

Basically the server is down.  I suppose the client's kernel can  
detect this is the case as soon as the ARP request for the server's  
MAC address times out, but normally we retry TCP connects for a while  
(even in this case) because we assume the server is coming back up as  
quickly as it can, and want to catch it as quickly as possible.

But we can't shorten this timeout in the general case, I don't think.   
It could take quite a while on a busy network or if a long round trip  
is involved for a TCP connect to complete.

> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>> On Aug 10, 2009, at 2:29 PM, Carlos André wrote:
>>>
>>> Bruce, no... you're right.  I'm describing a situation where my  
>>> server
>>> died... i need mount fail faster (10 or 15 secs max) than 3 minutes
>>> and 9 seconds...
>>
>> The 189 second timeout is likely how long it takes the kernel to  
>> give up
>> trying to connect a TCP socket to the server (6 SYN attempts with
>> exponential retries, or something like that).  For stock CentOS  
>> 5.3, I think
>> user space does only a DNS lookup for normal NFSv4 mounts -- the  
>> kernel just
>> tries to connect a TCP socket to port 2049, with no preceding rpcbind
>> request.
>>
>> Carlos, let us know if you have replaced any NFS-related CentOS  
>> components
>> (kernel, nfs-utils) with something you've built yourself.
>>
>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>
>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>
>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos André <candrecn@gmail.com>  
>>>>> wrote:
>>>>>>
>>>>>> Anyone ?
>>>>>>
>>>>>> 2009/7/29 Carlos André <candrecn@gmail.com>:
>>>>>>>
>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
>>>>>>> Kerberos
>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i get a
>>>>>>> LOOOOOOONG
>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>
>>>>>>> Since i need mount some (3 to 6) dirs at user logon process,  
>>>>>>> if mount
>>>>>>> hangs,
>>>>>>> user logon hangs. Then i want configure it to timeout (if  
>>>>>>> server down)
>>>>>>> after
>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>
>>>>>>> I already make a lab and tried a LOT of combinations, there my
>>>>>>> findings
>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using  
>>>>>>> basic
>>>>>>> command
>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>> sec=krb5,proto=<tcp/udp>) from NFS client:
>>>>>>>
>>>>>>> - Once i try access mount point using AutoFS (proto=tcp OR  
>>>>>>> proto=udp)
>>>>>>> it
>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error  
>>>>>>> (mount:
>>>>>>> mount to
>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>
>>>>> Sounds like you're hitting the server's grace period.
>>>>
>>>> I thought he was describing a situation where the server the server
>>>> is completely gone and isn't coming back, and wondering how to  
>>>> make the
>>>> mount fail faster.  But I may be misunderstanding.
>>>>
>>>> --b.
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



