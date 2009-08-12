Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52915 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbZHLO1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 10:27:18 -0400
Message-ID: <4A82D13D.2030705@redhat.com>
Date: Wed, 12 Aug 2009 22:27:09 +0800
From: Ian Kent <ikent@redhat.com>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>	 <4A7BCCCA.4020307@panasas.com> <20090807140425.GA18298@fieldses.org>	 <f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>	 <A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>	 <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>	 <f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>	 <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>	 <f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>	 <7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com> <f6ce31e30908111937jbd174dev6de131840da5ed4a@mail.gmail.com>
In-Reply-To: <f6ce31e30908111937jbd174dev6de131840da5ed4a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Carlos André wrote:
> Chuck,
> Since we'll use some NFS servers, and (some) they are not critical to
> user work (if they're down, user can just sit and wait for them
> working on something else like  a webapp, printing, etc...) and if we
> lose a server or a router (worst case) acumulative timeouts on
> workstation login-boot process will make users try kill us (lol). A
> acceptable timeout(first mount fail timeout) per automount try is
> something around 10-15 (max) seconds. For us the best is a option to
> permit us to do adjustments (1 to X secs), and putting this like a new
> feature/non-default option will not mess with another users.... I dont
> wanna make a mess on sources by myself just to modify automounter for
> our needs, I just want the "right" solution in our case...

But that also begs the question.
What version of autofs is in use?

The latest versions have the ability to specify a time to wait before
killing the mount process but I think that itself is an option that
hasn't had the bugs worked out yet because the RPC layer seems to want
to refuse to give up even when we kill the process.

Perhaps we can work on this further, depending on your version
constraints, of course.

> 
> Thanks for help.
> 
> 2009/8/11 Chuck Lever <chuck.lever@oracle.com>:
>> On Aug 11, 2009, at 8:41 AM, Carlos André wrote:
>>> This long timeout is good if workstation need mount a critical
>>> directory using /etc/fstab on boot (for example)..
>>> But in my case, using this loooong timeout doesnt make any sense,
>>> since autofs retry mount directory on-access. This in fact gives me
>>> alot of headaches, coz user login 'll just hangs if one server goes
>>> down for any reason, and will again hangs if user try access directory
>>> pointing to a NFS down server...
>> "retry=0" means the mount command will fail as soon as the first mount(2)
>> system call fails.  When you set SYN retries to 1, this means after 9
>> seconds, the connect fails, and that causes the mount(2) system call to
>> fail.
>>
>> Recent conversations with Ian suggested that a long timeout was desired for
>> automounter as well as other cases.  Ian, is there something else we need to
>> consider to determine the correct retry timeout for NFS/TCP mount points
>> handled via automounter?  How should mount.nfs wait so we don't make other
>> use cases worse?  (Looks like most of the history is intact below).
>>
>> How long do you think is appropriate for the automounter to wait if the
>> server is down, in your case, Carlos?
>>
>>> Am losing something or there have was something weirdo...!?
>>> ------------------------------------------------
>>> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_retries  [DEFAULT]
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=tcp,retry=1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    3m9.000s
>>> user    0m0.002s
>>> sys     0m0.001s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=krb5p,proto=tcp,retry=1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    3m9.000s
>>> user    0m0.000s
>>> sys     0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=tcp,retry=0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    3m9.001s
>>> user    0m0.000s
>>> sys     0m0.003s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=krb5p,proto=tcp,retry=0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    3m9.001s
>>> user    0m0.002s
>>> sys     0m0.001s
>>>
>>> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries [ 5 to 1 ]
>>>
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=tcp,retry=1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 6]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    1m3.002s
>>> user    0m0.000s
>>> sys     0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=krb5p,proto=tcp,retry=1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 13]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    2m6.000s
>>> user    0m0.000s
>>> sys     0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=tcp,retry=0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    0m9.003s
>>> user    0m0.001s
>>> sys     0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=krb5p,proto=tcp,retry=0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 13]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    2m6.001s
>>> user    0m0.001s
>>> sys     0m0.002s
>>> [root@KSTATION ~]#
>>> ------------------------------------------------
>>> max timeout goes to 2m6s changing tcp_syn_retries from 5 to 1... and
>>> using retry=0 without kerberos I got only 9s...
>>>
>>> *sigh*
>>>
>>>
>>>
>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>> On Aug 10, 2009, at 4:05 PM, Carlos André wrote:
>>>>> Something funny: Using default tcp_syn_retries (5) i got
>>>>> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retries to
>>>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>>> Right.  Normally the RPC client calls the kernel's socket connect
>>>> function,
>>>> which does 6 SYN retries.  That one call usually takes longer than the
>>>> RPC
>>>> client's connect timeout, so it only makes one connect call, and then
>>>> fails.
>>>>
>>>> Reducing the number of SYN retries per connect attempt causes the RPC
>>>> client
>>>> to retry the connect call until its connect timeout expires.  Each
>>>> connect
>>>> call resets the SYN timeout to 3 seconds.
>>>>
>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>> sec=krb5p,proto=tcp
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>
>>>>> real    3m9.000s
>>>>> user    0m0.000s
>>>>> sys     0m0.002s
>>>>>
>>>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>> sec=krb5p,proto=tcp  ("retry=1" = no change)
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>
>>>>> real    2m6.004s
>>>>> user    0m0.000s
>>>>> sys     0m0.004s
>>>>>
>>>>> (3,6,3,6... secs interval)
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> 2009/8/10 Carlos André <candrecn@gmail.com>:
>>>>>> No, i'm just using packages from CentOS repo...
>>>>>>
>>>>>> And u're right about expo retries... with tcpdump i've monitored
>>>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
>>>>>> 2049...
>>>>>> I tried use "retry=1" option on mount without any change... I dont
>>>>>> want change source or tcp timers... just NFSv4 client.
>>>>>>
>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>> On Aug 10, 2009, at 2:29 PM, Carlos André wrote:
>>>>>>>> Bruce, no... you're right.  I'm describing a situation where my
>>>>>>>> server
>>>>>>>> died... i need mount fail faster (10 or 15 secs max) than 3 minutes
>>>>>>>> and 9 seconds...
>>>>>>> The 189 second timeout is likely how long it takes the kernel to give
>>>>>>> up
>>>>>>> trying to connect a TCP socket to the server (6 SYN attempts with
>>>>>>> exponential retries, or something like that).  For stock CentOS 5.3, I
>>>>>>> think
>>>>>>> user space does only a DNS lookup for normal NFSv4 mounts -- the
>>>>>>> kernel
>>>>>>> just
>>>>>>> tries to connect a TCP socket to port 2049, with no preceding rpcbind
>>>>>>> request.
>>>>>>>
>>>>>>> Carlos, let us know if you have replaced any NFS-related CentOS
>>>>>>> components
>>>>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>>>>
>>>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos André <candrecn@gmail.com>
>>>>>>>>>> wrote:
>>>>>>>>>>> Anyone ?
>>>>>>>>>>>
>>>>>>>>>>> 2009/7/29 Carlos André <candrecn@gmail.com>:
>>>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
>>>>>>>>>>>> Kerberos
>>>>>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i get a
>>>>>>>>>>>> LOOOOOOONG
>>>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>>>>>
>>>>>>>>>>>> Since i need mount some (3 to 6) dirs at user logon process, if
>>>>>>>>>>>> mount
>>>>>>>>>>>> hangs,
>>>>>>>>>>>> user logon hangs. Then i want configure it to timeout (if server
>>>>>>>>>>>> down)
>>>>>>>>>>>> after
>>>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>>>
>>>>>>>>>>>> I already make a lab and tried a LOT of combinations, there my
>>>>>>>>>>>> findings
>>>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using
>>>>>>>>>>>> basic
>>>>>>>>>>>> command
>>>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>>>>>> sec=krb5,proto=<tcp/udp>) from NFS client:
>>>>>>>>>>>>
>>>>>>>>>>>> - Once i try access mount point using AutoFS (proto=tcp OR
>>>>>>>>>>>> proto=udp)
>>>>>>>>>>>> it
>>>>>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error
>>>>>>>>>>>> (mount:
>>>>>>>>>>>> mount to
>>>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>>>> I thought he was describing a situation where the server the server
>>>>>>>>> is completely gone and isn't coming back, and wondering how to make
>>>>>>>>> the
>>>>>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>>>>>
>>>>>>>>> --b.
>>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>>>>>> in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>

