Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:33073 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbZHKMlY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 08:41:24 -0400
Received: by vws2 with SMTP id 2so3316686vws.4
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2009 05:41:25 -0700 (PDT)
In-Reply-To: <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	 <f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
	 <4A7BCCCA.4020307@panasas.com> <20090807140425.GA18298@fieldses.org>
	 <f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
	 <A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
	 <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
	 <f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>
	 <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>
Date: Tue, 11 Aug 2009 09:41:24 -0300
Message-ID: <f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This long timeout is good if workstation need mount a critical
directory using /etc/fstab on boot (for example)..
But in my case, using this loooong timeout doesnt make any sense,
since autofs retry mount directory on-access. This in fact gives me
alot of headaches, coz user login 'll just hangs if one server goes
down for any reason, and will again hangs if user try access directory
pointing to a NFS down server...


Am losing something or there have was something weirdo...!?
------------------------------------------------
[root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_retries  [DEFAULT]
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o proto=tcp,retry=1
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    3m9.000s
user    0m0.002s
sys     0m0.001s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
sec=krb5p,proto=tcp,retry=1
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    3m9.000s
user    0m0.000s
sys     0m0.002s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o proto=tcp,retry=0
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    3m9.001s
user    0m0.000s
sys     0m0.003s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
sec=krb5p,proto=tcp,retry=0
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    3m9.001s
user    0m0.002s
sys     0m0.001s

[root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries [ 5 to 1 ]

[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o proto=tcp,retry=1
mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 6]
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    1m3.002s
user    0m0.000s
sys     0m0.002s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
sec=krb5p,proto=tcp,retry=1
mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 13]
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    2m6.000s
user    0m0.000s
sys     0m0.002s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o proto=tcp,retry=0
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    0m9.003s
user    0m0.001s
sys     0m0.002s
[root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
sec=krb5p,proto=tcp,retry=0
mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [x 13]
mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).

real    2m6.001s
user    0m0.001s
sys     0m0.002s
[root@KSTATION ~]#
------------------------------------------------
max timeout goes to 2m6s changing tcp_syn_retries from 5 to 1... and
using retry=0 without kerberos I got only 9s...

*sigh*



2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
> On Aug 10, 2009, at 4:05 PM, Carlos André wrote:
>>
>> Something funny: Using default tcp_syn_retries (5) i got
>> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retries to
>> 1 i got "3,6,3,6,3,6..." secs interval...
>
> Right.  Normally the RPC client calls the kernel's socket connect function,
> which does 6 SYN retries.  That one call usually takes longer than the RPC
> client's connect timeout, so it only makes one connect call, and then fails.
>
> Reducing the number of SYN retries per connect attempt causes the RPC client
> to retry the connect call until its connect timeout expires.  Each connect
> call resets the SYN timeout to 3 seconds.
>
>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>> sec=krb5p,proto=tcp
>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>
>> real    3m9.000s
>> user    0m0.000s
>> sys     0m0.002s
>>
>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>> sec=krb5p,proto=tcp  ("retry=1" = no change)
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>
>> real    2m6.004s
>> user    0m0.000s
>> sys     0m0.004s
>>
>> (3,6,3,6... secs interval)
>>
>>
>>
>>
>> 2009/8/10 Carlos André <candrecn@gmail.com>:
>>>
>>> No, i'm just using packages from CentOS repo...
>>>
>>> And u're right about expo retries... with tcpdump i've monitored
>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
>>> 2049...
>>> I tried use "retry=1" option on mount without any change... I dont
>>> want change source or tcp timers... just NFSv4 client.
>>>
>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>
>>>> On Aug 10, 2009, at 2:29 PM, Carlos André wrote:
>>>>>
>>>>> Bruce, no... you're right.  I'm describing a situation where my server
>>>>> died... i need mount fail faster (10 or 15 secs max) than 3 minutes
>>>>> and 9 seconds...
>>>>
>>>> The 189 second timeout is likely how long it takes the kernel to give up
>>>> trying to connect a TCP socket to the server (6 SYN attempts with
>>>> exponential retries, or something like that).  For stock CentOS 5.3, I
>>>> think
>>>> user space does only a DNS lookup for normal NFSv4 mounts -- the kernel
>>>> just
>>>> tries to connect a TCP socket to port 2049, with no preceding rpcbind
>>>> request.
>>>>
>>>> Carlos, let us know if you have replaced any NFS-related CentOS
>>>> components
>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>
>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>
>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>>
>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos André <candrecn@gmail.com>
>>>>>>> wrote:
>>>>>>>>
>>>>>>>> Anyone ?
>>>>>>>>
>>>>>>>> 2009/7/29 Carlos André <candrecn@gmail.com>:
>>>>>>>>>
>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
>>>>>>>>> Kerberos
>>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i get a
>>>>>>>>> LOOOOOOONG
>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>>
>>>>>>>>> Since i need mount some (3 to 6) dirs at user logon process, if
>>>>>>>>> mount
>>>>>>>>> hangs,
>>>>>>>>> user logon hangs. Then i want configure it to timeout (if server
>>>>>>>>> down)
>>>>>>>>> after
>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>
>>>>>>>>> I already make a lab and tried a LOT of combinations, there my
>>>>>>>>> findings
>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using basic
>>>>>>>>> command
>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>>> sec=krb5,proto=<tcp/udp>) from NFS client:
>>>>>>>>>
>>>>>>>>> - Once i try access mount point using AutoFS (proto=tcp OR
>>>>>>>>> proto=udp)
>>>>>>>>> it
>>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error (mount:
>>>>>>>>> mount to
>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>>
>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>
>>>>>> I thought he was describing a situation where the server the server
>>>>>> is completely gone and isn't coming back, and wondering how to make
>>>>>> the
>>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>>
>>>>>> --b.
>>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>>>
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
