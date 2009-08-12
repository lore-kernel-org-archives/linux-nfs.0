From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Wed, 12 Aug 2009 12:00:19 -0300
Message-ID: <f6ce31e30908120800i2cc82005s695d1097df554b58@mail.gmail.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	 <20090807140425.GA18298@fieldses.org>
	 <f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
	 <A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
	 <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
	 <f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>
	 <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>
	 <f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>
	 <7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com>
	 <4A82CE18.6020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Ian Kent <ikent@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:57143 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbZHLPAT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:00:19 -0400
Received: by vws2 with SMTP id 2so63644vws.4
        for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2009 08:00:19 -0700 (PDT)
In-Reply-To: <4A82CE18.6020401@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ian,
I'm getting crazy trying put "retry=3D" to work on mount... this option
just DONT WORK if use proto=3Dtcp and/OR kerberos (sec=3Dkrb5/krb5i/krb=
5p)
like you can see on my previous emails...

I appreciate any help.

Carlos.


2009/8/12 Ian Kent <ikent@redhat.com>:
> Chuck Lever wrote:
>> On Aug 11, 2009, at 8:41 AM, Carlos Andr=E9 wrote:
>>> This long timeout is good if workstation need mount a critical
>>> directory using /etc/fstab on boot (for example)..
>>> But in my case, using this loooong timeout doesnt make any sense,
>>> since autofs retry mount directory on-access. This in fact gives me
>>> alot of headaches, coz user login 'll just hangs if one server goes
>>> down for any reason, and will again hangs if user try access direct=
ory
>>> pointing to a NFS down server...
>>
>> "retry=3D0" means the mount command will fail as soon as the first
>> mount(2) system call fails. =A0When you set SYN retries to 1, this m=
eans
>> after 9 seconds, the connect fails, and that causes the mount(2) sys=
tem
>> call to fail.
>>
>> Recent conversations with Ian suggested that a long timeout was desi=
red
>> for automounter as well as other cases. =A0Ian, is there something e=
lse we
>> need to consider to determine the correct retry timeout for NFS/TCP
>> mount points handled via automounter? =A0How should mount.nfs wait s=
o we
>> don't make other use cases worse? =A0(Looks like most of the history=
 is
>> intact below).
>
> Of course we know that autofs is entirely at the mercy of mount(8) (a=
nd
> mount.nfs in particular). This has always been a difficult situation =
for
> the automounter because interactive mount invocations should wait. Bu=
t I
> believe automount mounts should always time out quickly, but that lea=
ds
> to its own set of problems, especially when home directories are conc=
erned.
>
> I think adding "retry=3D0" is the right thing to do myself but I'm no=
t
> certain that will work as we expect. I'll have to do some experimenta=
tion.
>
>>
>> How long do you think is appropriate for the automounter to wait if =
the
>> server is down, in your case, Carlos?
>>
>>> Am losing something or there have was something weirdo...!?
>>> ------------------------------------------------
>>> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_retries =A0[=
DEFAULT]
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=3Dtcp,retry=3D1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A03m9.000s
>>> user =A0 =A00m0.002s
>>> sys =A0 =A0 0m0.001s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A03m9.000s
>>> user =A0 =A00m0.000s
>>> sys =A0 =A0 0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=3Dtcp,retry=3D0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A03m9.001s
>>> user =A0 =A00m0.000s
>>> sys =A0 =A0 0m0.003s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A03m9.001s
>>> user =A0 =A00m0.002s
>>> sys =A0 =A0 0m0.001s
>>>
>>> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries [ 5 =
to 1 ]
>>>
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=3Dtcp,retry=3D1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =
[x 6]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A01m3.002s
>>> user =A0 =A00m0.000s
>>> sys =A0 =A0 0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =
[x 13]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A02m6.000s
>>> user =A0 =A00m0.000s
>>> sys =A0 =A0 0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> proto=3Dtcp,retry=3D0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A00m9.003s
>>> user =A0 =A00m0.001s
>>> sys =A0 =A0 0m0.002s
>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =
[x 13]
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real =A0 =A02m6.001s
>>> user =A0 =A00m0.001s
>>> sys =A0 =A0 0m0.002s
>>> [root@KSTATION ~]#
>>> ------------------------------------------------
>>> max timeout goes to 2m6s changing tcp_syn_retries from 5 to 1... an=
d
>>> using retry=3D0 without kerberos I got only 9s...
>>>
>>> *sigh*
>>>
>>>
>>>
>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>> On Aug 10, 2009, at 4:05 PM, Carlos Andr=E9 wrote:
>>>>>
>>>>> Something funny: Using default tcp_syn_retries (5) i got
>>>>> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retrie=
s to
>>>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>>>
>>>> Right. =A0Normally the RPC client calls the kernel's socket connec=
t
>>>> function,
>>>> which does 6 SYN retries. =A0That one call usually takes longer th=
an
>>>> the RPC
>>>> client's connect timeout, so it only makes one connect call, and t=
hen
>>>> fails.
>>>>
>>>> Reducing the number of SYN retries per connect attempt causes the =
RPC
>>>> client
>>>> to retry the connect call until its connect timeout expires. =A0Ea=
ch
>>>> connect
>>>> call resets the SYN timeout to 3 seconds.
>>>>
>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>> sec=3Dkrb5p,proto=3Dtcp
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up=
).
>>>>>
>>>>> real =A0 =A03m9.000s
>>>>> user =A0 =A00m0.000s
>>>>> sys =A0 =A0 0m0.002s
>>>>>
>>>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>> sec=3Dkrb5p,proto=3Dtcp =A0("retry=3D1" =3D no change)
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying)=
=2E
>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up=
).
>>>>>
>>>>> real =A0 =A02m6.004s
>>>>> user =A0 =A00m0.000s
>>>>> sys =A0 =A0 0m0.004s
>>>>>
>>>>> (3,6,3,6... secs interval)
>>>>>
>>>>>
>>>>>
>>>>>
>>>>> 2009/8/10 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>
>>>>>> No, i'm just using packages from CentOS repo...
>>>>>>
>>>>>> And u're right about expo retries... with tcpdump i've monitored
>>>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on po=
rt
>>>>>> 2049...
>>>>>> I tried use "retry=3D1" option on mount without any change... I =
dont
>>>>>> want change source or tcp timers... just NFSv4 client.
>>>>>>
>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>
>>>>>>> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>>>>>>>
>>>>>>>> Bruce, no... you're right. =A0I'm describing a situation where=
 my
>>>>>>>> server
>>>>>>>> died... i need mount fail faster (10 or 15 secs max) than 3 mi=
nutes
>>>>>>>> and 9 seconds...
>>>>>>>
>>>>>>> The 189 second timeout is likely how long it takes the kernel t=
o
>>>>>>> give up
>>>>>>> trying to connect a TCP socket to the server (6 SYN attempts wi=
th
>>>>>>> exponential retries, or something like that). =A0For stock Cent=
OS
>>>>>>> 5.3, I
>>>>>>> think
>>>>>>> user space does only a DNS lookup for normal NFSv4 mounts -- th=
e
>>>>>>> kernel
>>>>>>> just
>>>>>>> tries to connect a TCP socket to port 2049, with no preceding r=
pcbind
>>>>>>> request.
>>>>>>>
>>>>>>> Carlos, let us know if you have replaced any NFS-related CentOS
>>>>>>> components
>>>>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>>>>
>>>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>>>
>>>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>>>>>
>>>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail=
=2Ecom>
>>>>>>>>>> wrote:
>>>>>>>>>>>
>>>>>>>>>>> Anyone ?
>>>>>>>>>>>
>>>>>>>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>>>>>
>>>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to wor=
k with
>>>>>>>>>>>> Kerberos
>>>>>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i=
 get a
>>>>>>>>>>>> LOOOOOOONG
>>>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>>>>>
>>>>>>>>>>>> Since i need mount some (3 to 6) dirs at user logon proces=
s, if
>>>>>>>>>>>> mount
>>>>>>>>>>>> hangs,
>>>>>>>>>>>> user logon hangs. Then i want configure it to timeout (if =
server
>>>>>>>>>>>> down)
>>>>>>>>>>>> after
>>>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>>>
>>>>>>>>>>>> I already make a lab and tried a LOT of combinations, ther=
e my
>>>>>>>>>>>> findings
>>>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) usi=
ng
>>>>>>>>>>>> basic
>>>>>>>>>>>> command
>>>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>>>>>>>
>>>>>>>>>>>> - Once i try access mount point using AutoFS (proto=3Dtcp =
OR
>>>>>>>>>>>> proto=3Dudp)
>>>>>>>>>>>> it
>>>>>>>>>>>> hangs for 189 secs (3m9s: real =A03m9.001s) =A0until show =
error
>>>>>>>>>>>> (mount:
>>>>>>>>>>>> mount to
>>>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>>>>>
>>>>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>>>>
>>>>>>>>> I thought he was describing a situation where the server the =
server
>>>>>>>>> is completely gone and isn't coming back, and wondering how t=
o make
>>>>>>>>> the
>>>>>>>>> mount fail faster. =A0But I may be misunderstanding.
>>>>>>>>>
>>>>>>>>> --b.
>>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>>>>> linux-nfs" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-inf=
o.html
>>>>>>>
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>
>
