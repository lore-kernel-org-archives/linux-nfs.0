Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-Id: <7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
In-Reply-To: <f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Tue, 11 Aug 2009 16:00:34 -0400
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	<f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
	<4A7BCCCA.4020307@panasas.com>
	<20090807140425.GA18298@fieldses.org>
	<f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
	<A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
	<f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
	<f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>
	<4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>
	<f6ce31e30908110541g7e1354ffs59b74ad808578742@mail.gmail.com>
Cc: Ian Kent <ikent@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"; Format="flowed"; DelSp="yes"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Aug 11, 2009, at 8:41 AM, Carlos Andr=E9 wrote:
> This long timeout is good if workstation need mount a critical
> directory using /etc/fstab on boot (for example)..
> But in my case, using this loooong timeout doesnt make any sense,
> since autofs retry mount directory on-access. This in fact gives me
> alot of headaches, coz user login 'll just hangs if one server goes
> down for any reason, and will again hangs if user try access directory
> pointing to a NFS down server...

"retry=3D0" means the mount command will fail as soon as the first =20
mount(2) system call fails.  When you set SYN retries to 1, this means =20
after 9 seconds, the connect fails, and that causes the mount(2) =20
system call to fail.

Recent conversations with Ian suggested that a long timeout was =20
desired for automounter as well as other cases.  Ian, is there =20
something else we need to consider to determine the correct retry =20
timeout for NFS/TCP mount points handled via automounter?  How should =20
mount.nfs wait so we don't make other use cases worse?  (Looks like =20
most of the history is intact below).

How long do you think is appropriate for the automounter to wait if =20
the server is down, in your case, Carlos?

> Am losing something or there have was something weirdo...!?
> ------------------------------------------------
> [root@KSTATION ~]# echo 5 > /proc/sys/net/ipv4/tcp_syn_retries  =20
> [DEFAULT]
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o =20
> proto=3Dtcp,retry=3D1
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    3m9.000s
> user    0m0.002s
> sys     0m0.001s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    3m9.000s
> user    0m0.000s
> sys     0m0.002s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o =20
> proto=3Dtcp,retry=3D0
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    3m9.001s
> user    0m0.000s
> sys     0m0.003s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    3m9.001s
> user    0m0.002s
> sys     0m0.001s
>
> [root@KSTATION ~]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries [ 5 =20
> to 1 ]
>
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o =20
> proto=3Dtcp,retry=3D1
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =20
> [x 6]
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    1m3.002s
> user    0m0.000s
> sys     0m0.002s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp,retry=3D1
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =20
> [x 13]
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    2m6.000s
> user    0m0.000s
> sys     0m0.002s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o =20
> proto=3Dtcp,retry=3D0
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    0m9.003s
> user    0m0.001s
> sys     0m0.002s
> [root@KSTATION ~]# time mount 1.2.3.4:/blabla /tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp,retry=3D0
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying). =20
> [x 13]
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    2m6.001s
> user    0m0.001s
> sys     0m0.002s
> [root@KSTATION ~]#
> ------------------------------------------------
> max timeout goes to 2m6s changing tcp_syn_retries from 5 to 1... and
> using retry=3D0 without kerberos I got only 9s...
>
> *sigh*
>
>
>
> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>> On Aug 10, 2009, at 4:05 PM, Carlos Andr=E9 wrote:
>>>
>>> Something funny: Using default tcp_syn_retries (5) i got
>>> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retries =20
>>> to
>>> 1 i got "3,6,3,6,3,6..." secs interval...
>>
>> Right.  Normally the RPC client calls the kernel's socket connect =20
>> function,
>> which does 6 SYN retries.  That one call usually takes longer than =20
>> the RPC
>> client's connect timeout, so it only makes one connect call, and =20
>> then fails.
>>
>> Reducing the number of SYN retries per connect attempt causes the =20
>> RPC client
>> to retry the connect call until its connect timeout expires.  Each =20
>> connect
>> call resets the SYN timeout to 3 seconds.
>>
>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    3m9.000s
>>> user    0m0.000s
>>> sys     0m0.002s
>>>
>>> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
>>> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
>>> sec=3Dkrb5p,proto=3Dtcp  ("retry=3D1" =3D no change)
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
>>> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>>>
>>> real    2m6.004s
>>> user    0m0.000s
>>> sys     0m0.004s
>>>
>>> (3,6,3,6... secs interval)
>>>
>>>
>>>
>>>
>>> 2009/8/10 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>
>>>> No, i'm just using packages from CentOS repo...
>>>>
>>>> And u're right about expo retries... with tcpdump i've monitored
>>>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
>>>> 2049...
>>>> I tried use "retry=3D1" option on mount without any change... I dont
>>>> want change source or tcp timers... just NFSv4 client.
>>>>
>>>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>>>>
>>>>> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>>>>>
>>>>>> Bruce, no... you're right.  I'm describing a situation where my =20
>>>>>> server
>>>>>> died... i need mount fail faster (10 or 15 secs max) than 3 =20
>>>>>> minutes
>>>>>> and 9 seconds...
>>>>>
>>>>> The 189 second timeout is likely how long it takes the kernel to =20
>>>>> give up
>>>>> trying to connect a TCP socket to the server (6 SYN attempts with
>>>>> exponential retries, or something like that).  For stock CentOS =20
>>>>> 5.3, I
>>>>> think
>>>>> user space does only a DNS lookup for normal NFSv4 mounts -- the =20
>>>>> kernel
>>>>> just
>>>>> tries to connect a TCP socket to port 2049, with no preceding =20
>>>>> rpcbind
>>>>> request.
>>>>>
>>>>> Carlos, let us know if you have replaced any NFS-related CentOS
>>>>> components
>>>>> (kernel, nfs-utils) with something you've built yourself.
>>>>>
>>>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>>>
>>>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>>>
>>>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail.com>
>>>>>>>> wrote:
>>>>>>>>>
>>>>>>>>> Anyone ?
>>>>>>>>>
>>>>>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>>>
>>>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work =20
>>>>>>>>>> with
>>>>>>>>>> Kerberos
>>>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i =20
>>>>>>>>>> get a
>>>>>>>>>> LOOOOOOONG
>>>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>>>
>>>>>>>>>> Since i need mount some (3 to 6) dirs at user logon =20
>>>>>>>>>> process, if
>>>>>>>>>> mount
>>>>>>>>>> hangs,
>>>>>>>>>> user logon hangs. Then i want configure it to timeout (if =20
>>>>>>>>>> server
>>>>>>>>>> down)
>>>>>>>>>> after
>>>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>>>
>>>>>>>>>> I already make a lab and tried a LOT of combinations, there =20
>>>>>>>>>> my
>>>>>>>>>> findings
>>>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) =20
>>>>>>>>>> using basic
>>>>>>>>>> command
>>>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>>>>>
>>>>>>>>>> - Once i try access mount point using AutoFS (proto=3Dtcp OR
>>>>>>>>>> proto=3Dudp)
>>>>>>>>>> it
>>>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error =20
>>>>>>>>>> (mount:
>>>>>>>>>> mount to
>>>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>>>
>>>>>>>> Sounds like you're hitting the server's grace period.
>>>>>>>
>>>>>>> I thought he was describing a situation where the server the =20
>>>>>>> server
>>>>>>> is completely gone and isn't coming back, and wondering how to =20
>>>>>>> make
>>>>>>> the
>>>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>>>
>>>>>>> --b.
>>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-=20
>>>>>> nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-=20
>>>>>> info.html
>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>
>>>>>
>>>>>
>>>>>
>>>>
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



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
