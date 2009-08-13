From: Ian Kent <ikent@redhat.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Thu, 13 Aug 2009 22:19:59 +0800
Message-ID: <4A84210F.3020906@redhat.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>	
	<A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>	
	<f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>	
	<f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>	
	<4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>	
	<f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>	
	<7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com>	
	<4A82CE18.6020401@redhat.com>	
	<f6ce31e30908120800i2cc82005s695d1097df554b58@mail.gmail.com>	
	<4A82DDB1.1000109@redhat.com>
	<f6ce31e30908120940m6e9a093ayc59d7ef98e37b3d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <f6ce31e30908120940m6e9a093ayc59d7ef98e37b3d0@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Carlos Andr=E9 wrote:
> Today (2009-08-12) I'm using:
> kernel-2.6.18-128.2.1.el5
> autofs-5.0.1-0.rc2.102.el5_3.1

Thanks,

My mistake, the wait time I was referring to is used for umounts during
expires and is present in rev rc2.102.

It shouldn't be hard to add this for mount as well.
Would you like me to put something together?

Probably would be good to test something out to see if we can make a
difference with the killing mount after some configured timeout but, if
we make progress, probably the best way to deal with it is for you to
log a bug against rhel-5 so I can get it committed to the rhel package.
The possible issue is that I'm not sure if the RPC subsystem in the
above rhel kernel will respond well to process death with potential
outstanding requests. But we'll see.

> =

> =

> Look my last test:
> --------------------------------------------------------------
> [root@KSTATION areas]# time ls testdown
> ls: testdown: No such file or directory
> =

> real    3m9.025s
> user    0m0.000s
> sys     0m0.002s
> =

> =

> =

> =

> Aug 12 12:57:07 KSTATION automount[15471]: sun_mount: parse(sun):
> mounting root /misc/areas, mountpoint testdown, what
> 1.2.3.4:/areas/testdown, fstype nfs4, options
> acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0
> Aug 12 12:57:07 KSTATION automount[15471]: do_mount:
> 1.2.3.4:/areas/testdown /misc/areas/testdown type nfs4 options
> acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0 using module nfs4
> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(nfs):
> root=3D/misc/areas name=3Dtestdown what=3D1.2.3.4:/areas/testdown,
> fstype=3Dnfs4, options=3Dacl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0
> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(nfs):
> nfs options=3D"acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0", nosymlink=3D0, ro=
=3D0
> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(nfs):
> calling mkdir_path /misc/areas/testdown
> Aug 12 12:57:07 KSTATION automount[15471]: mount_mount: mount(nfs):
> calling mount -t nfs4 -s -o acl,sec=3Dkrb5p,proto=3Dtcp,retry=3D0
> 1.2.3.4:/areas/testdown /misc/areas/testdown
> Aug 12 12:58:12 KSTATION automount[15471]: st_expire: state 1 path /misc
> Aug 12 12:58:12 KSTATION automount[15471]: expire_proc: exp_proc =3D
> 3078093712 path /misc
> Aug 12 12:58:13 KSTATION automount[15471]: expire_proc_indirect: 2
> submounts remaining in /misc
> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup: got thid
> 3078093712 path /misc stat 3
> Aug 12 12:58:13 KSTATION automount[15471]: expire_cleanup: sigchld:
> exp 3078093712 finished, switching from 2 to 1
> Aug 12 12:58:13 KSTATION automount[15471]: st_ready: st_ready(): state
> =3D 2 path /misc
> Aug 12 12:59:28 KSTATION automount[15471]: st_expire: state 1 path /misc
> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc: exp_proc =3D
> 3078093712 path /misc
> Aug 12 12:59:28 KSTATION automount[15471]: expire_proc_indirect: 2
> submounts remaining in /misc
> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup: got thid
> 3078093712 path /misc stat 3
> Aug 12 12:59:28 KSTATION automount[15471]: expire_cleanup: sigchld:
> exp 3078093712 finished, switching from 2 to 1
> Aug 12 12:59:28 KSTATION automount[15471]: st_ready: st_ready(): state
> =3D 2 path /misc
> Aug 12 13:00:16 KSTATION automount[15471]: >> mount: mount to NFS
> server '1.2.3.4' failed: timed out (giving up).
> Aug 12 13:00:16 KSTATION automount[15471]: mount(nfs): nfs: mount
> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
> Aug 12 13:00:16 KSTATION automount[15471]: send_fail: token =3D 17
> Aug 12 13:00:16 KSTATION automount[15471]: failed to mount /misc/areas/te=
stdown
> Aug 12 13:00:43 KSTATION automount[15471]: st_expire: state 1 path /misc
> --------------------------------------------------------------
> =

> 2009/8/12 Ian Kent <ikent@redhat.com>:
>> Carlos Andr=E9 wrote:
>>> Hi Ian,
>>> I'm getting crazy trying put "retry=3D" to work on mount... this option
>>> just DONT WORK if use proto=3Dtcp and/OR kerberos (sec=3Dkrb5/krb5i/krb=
5p)
>>> like you can see on my previous emails...
>> Right, my mistake for not looking closely enough at post.
>>
>> Maybe this is related to the same sort of problem we had with mount in
>> the past, before the options parsing went into the kernel, where other
>> services, like portmapper (or rpcbind), were being done with different
>> timeout parameters before the RPC calls for mounting. That's just an
>> example as NFSv4 shouldn't be sensitive to portmapper anyway.
>>
>> But what version of autofs and kernel did you say you were using?
>>
>>> I appreciate any help.
>>>
>>> Carlos.
>>>
>>>
>>> 2009/8/12 Ian Kent <ikent@redhat.com>:
>>>> Chuck Lever wrote:
>>>>> On Aug 11, 2009, at 8:41 AM, Carlos Andr=E9 wrote:
>>>>>> This long timeout is good if workstation need mount a critical
>>>>>> directory using /etc/fstab on boot (for example)..
>>>>>> But in my case, using this loooong timeout doesnt make any sense,
>>>>>> since autofs retry mount directory on-access. This in fact gives me
>>>>>> alot of headaches, coz user login 'll just hangs if one server goes
>>>>>> down for any reason, and will again hangs if user try access directo=
ry
>>>>>> pointing to a NFS down server...
>>>>> "retry=3D0" means the mount command will fail as soon as the first
>>>>> mount(2) system call fails.  When you set SYN retries to 1, this means
>>>>> after 9 seconds, the connect fails, and that causes the mount(2) syst=
em
>>>>> call to fail.
>>>>>
>>>>> Recent conversations with Ian suggested that a long timeout was desir=
ed
>>>>> for automounter as well as other cases.  Ian, is there something else=
 we
>>>>> need to consider to determine the correct retry timeout for NFS/TCP
>>>>> mount points handled via automounter?  How should mount.nfs wait so we
>>>>> don't make other use cases worse?  (Looks like most of the history is
>>>>> intact below).
>>>> Of course we know that autofs is entirely at the mercy of mount(8) (and
>>>> mount.nfs in particular). This has always been a difficult situation f=
or
>>>> the automounter because interactive mount invocations should wait. But=
 I
>>>> believe automount mounts should always time out quickly, but that leads
>>>> to its own set of problems, especially when home directories are conce=
rned.
>>>>
>>>> I think adding "retry=3D0" is the right thing to do myself but I'm not
>>>> certain that will work as we expect. I'll have to do some experimentat=
ion.
>>>>
>>>>> How long do you think is appropriate for the automounter to wait if t=
he
>>>>> server is down, in your case, Carlos?
>>>>>
>>>>>> Am losing something or there have was something weirdo...!?
>>>>>> ------------------------------------------------
>>>>>> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_retries  [DEF=
AULT]
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> proto=3Dtcp,retry=3D1
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    3m9.000s
>>>>>> user    0m0.002s
>>>>>> sys     0m0.001s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    3m9.000s
>>>>>> user    0m0.000s
>>>>>> sys     0m0.002s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> proto=3Dtcp,retry=3D0
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    3m9.001s
>>>>>> user    0m0.000s
>>>>>> sys     0m0.003s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    3m9.001s
>>>>>> user    0m0.002s
>>>>>> sys     0m0.001s
>>>>>>
>>>>>> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries [ 5 t=
o 1 ]
>>>>>>
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> proto=3Dtcp,retry=3D1
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [=
x 6]
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    1m3.002s
>>>>>> user    0m0.000s
>>>>>> sys     0m0.002s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [=
x 13]
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    2m6.000s
>>>>>> user    0m0.000s
>>>>>> sys     0m0.002s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> proto=3Dtcp,retry=3D0
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    0m9.003s
>>>>>> user    0m0.001s
>>>>>> sys     0m0.002s
>>>>>> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
>>>>>> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). [=
x 13]
>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>
>>>>>> real    2m6.001s
>>>>>> user    0m0.001s
>>>>>> sys     0m0.002s
>>>>>> [root@KSTATION ~]#
>>>>>> ------------------------------------------------
>>>>>> max timeout goes to 2m6s changing tcp_syn_retries from 5 to 1... and
>>>>>> using retry=3D0 without kerberos I got only 9s...
>>>>>>
>>>>>> *sigh*
>>>>>>
>>>>>>
>>>>>>
>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>> On Aug 10, 2009, at 4:05 PM, Carlos Andr=E9 wrote:
>>>>>>>> Something funny: Using default tcp_syn_retries (5) i got
>>>>>>>> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retries=
 to
>>>>>>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>>>>>> Right.  Normally the RPC client calls the kernel's socket connect
>>>>>>> function,
>>>>>>> which does 6 SYN retries.  That one call usually takes longer than
>>>>>>> the RPC
>>>>>>> client's connect timeout, so it only makes one connect call, and th=
en
>>>>>>> fails.
>>>>>>>
>>>>>>> Reducing the number of SYN retries per connect attempt causes the R=
PC
>>>>>>> client
>>>>>>> to retry the connect call until its connect timeout expires.  Each
>>>>>>> connect
>>>>>>> call resets the SYN timeout to 3 seconds.
>>>>>>>
>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>>>>> sec=3Dkrb5p,proto=3Dtcp
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>>>
>>>>>>>> real    3m9.000s
>>>>>>>> user    0m0.000s
>>>>>>>> sys     0m0.002s
>>>>>>>>
>>>>>>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
>>>>>>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>>>>>>> sec=3Dkrb5p,proto=3Dtcp  ("retry=3D1" =3D no change)
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>>>>>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>>>>>>
>>>>>>>> real    2m6.004s
>>>>>>>> user    0m0.000s
>>>>>>>> sys     0m0.004s
>>>>>>>>
>>>>>>>> (3,6,3,6... secs interval)
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> 2009/8/10 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>> No, i'm just using packages from CentOS repo...
>>>>>>>>>
>>>>>>>>> And u're right about expo retries... with tcpdump i've monitored
>>>>>>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
>>>>>>>>> 2049...
>>>>>>>>> I tried use "retry=3D1" option on mount without any change... I d=
ont
>>>>>>>>> want change source or tcp timers... just NFSv4 client.
>>>>>>>>>
>>>>>>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>>>>>> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>>>>>>>>>> Bruce, no... you're right.  I'm describing a situation where my
>>>>>>>>>>> server
>>>>>>>>>>> died... i need mount fail faster (10 or 15 secs max) than 3 min=
utes
>>>>>>>>>>> and 9 seconds...
>>>>>>>>>> The 189 second timeout is likely how long it takes the kernel to
>>>>>>>>>> give up
>>>>>>>>>> trying to connect a TCP socket to the server (6 SYN attempts with
>>>>>>>>>> exponential retries, or something like that).  For stock CentOS
>>>>>>>>>> 5.3, I
>>>>>>>>>> think
>>>>>>>>>> user space does only a DNS lookup for normal NFSv4 mounts -- the
>>>>>>>>>> kernel
>>>>>>>>>> just
>>>>>>>>>> tries to connect a TCP socket to port 2049, with no preceding rp=
cbind
>>>>>>>>>> request.
>>>>>>>>>>
>>>>>>>>>> Carlos, let us know if you have replaced any NFS-related CentOS
>>>>>>>>>> components
>>>>>>>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>>>>>>>
>>>>>>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail.=
com>
>>>>>>>>>>>>> wrote:
>>>>>>>>>>>>>> Anyone ?
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work=
 with
>>>>>>>>>>>>>>> Kerberos
>>>>>>>>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i =
get a
>>>>>>>>>>>>>>> LOOOOOOONG
>>>>>>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Since i need mount some (3 to 6) dirs at user logon process=
, if
>>>>>>>>>>>>>>> mount
>>>>>>>>>>>>>>> hangs,
>>>>>>>>>>>>>>> user logon hangs. Then i want configure it to timeout (if s=
erver
>>>>>>>>>>>>>>> down)
>>>>>>>>>>>>>>> after
>>>>>>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> I already make a lab and tried a LOT of combinations, there=
 my
>>>>>>>>>>>>>>> findings
>>>>>>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using
>>>>>>>>>>>>>>> basic
>>>>>>>>>>>>>>> command
>>>>>>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>>>>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> - Once i try access mount point using AutoFS (proto=3Dtcp OR
>>>>>>>>>>>>>>> proto=3Dudp)
>>>>>>>>>>>>>>> it
>>>>>>>>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error
>>>>>>>>>>>>>>> (mount:
>>>>>>>>>>>>>>> mount to
>>>>>>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>>>>>>> I thought he was describing a situation where the server the s=
erver
>>>>>>>>>>>> is completely gone and isn't coming back, and wondering how to=
 make
>>>>>>>>>>>> the
>>>>>>>>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>>>>>>>>
>>>>>>>>>>>> --b.
>>>>>>>>>>>>
>>>>>>>>>>> --
>>>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe
>>>>>>>>>>> linux-nfs" in
>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
>>>>>>>>>> --
>>>>>>>>>> Chuck Lever
>>>>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>
>>>>>
>>>>>
>>
