Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-Id: <4974ED30-D8CA-47B0-9D8F-BCD4410132FC@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
In-Reply-To: <f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Mon, 10 Aug 2009 16:35:22 -0400
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	<f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
	<4A7BCCCA.4020307@panasas.com>
	<20090807140425.GA18298@fieldses.org>
	<f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
	<A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
	<f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
	<f6ce31e30908101305n3a5b88ceo6b56b43f750b8548@mail.gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
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

On Aug 10, 2009, at 4:05 PM, Carlos Andr=E9 wrote:
> Something funny: Using default tcp_syn_retries (5) i got
> "3,6,12,24,48,96" secs interval... but if i change tcp_syn_retries to
> 1 i got "3,6,3,6,3,6..." secs interval...

Right.  Normally the RPC client calls the kernel's socket connect =20
function, which does 6 SYN retries.  That one call usually takes =20
longer than the RPC client's connect timeout, so it only makes one =20
connect call, and then fails.

Reducing the number of SYN retries per connect attempt causes the RPC =20
client to retry the connect call until its connect timeout expires.  =20
Each connect call resets the SYN timeout to 3 seconds.

> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    3m9.000s
> user    0m0.000s
> sys     0m0.002s
>
> [root@KSERVER /]# echo 1 > /proc/sys/net/ipv4/tcp_syn_retries
> [root@KSERVER mnt]# time mount 1.2.3.4:/blabla tmp/ -t nfs4 -o
> sec=3Dkrb5p,proto=3Dtcp  ("retry=3D1" =3D no change)
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (retrying).
> mount: mount to NFS server '1.2.3.4' failed: timed out (giving up).
>
> real    2m6.004s
> user    0m0.000s
> sys     0m0.004s
>
> (3,6,3,6... secs interval)
>
>
>
>
> 2009/8/10 Carlos Andr=E9 <candrecn@gmail.com>:
>> No, i'm just using packages from CentOS repo...
>>
>> And u're right about expo retries... with tcpdump i've monitored
>> traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
>> 2049...
>> I tried use "retry=3D1" option on mount without any change... I dont
>> want change source or tcp timers... just NFSv4 client.
>>
>> 2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
>>> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>>>
>>>> Bruce, no... you're right.  I'm describing a situation where my =20
>>>> server
>>>> died... i need mount fail faster (10 or 15 secs max) than 3 minutes
>>>> and 9 seconds...
>>>
>>> The 189 second timeout is likely how long it takes the kernel to =20
>>> give up
>>> trying to connect a TCP socket to the server (6 SYN attempts with
>>> exponential retries, or something like that).  For stock CentOS =20
>>> 5.3, I think
>>> user space does only a DNS lookup for normal NFSv4 mounts -- the =20
>>> kernel just
>>> tries to connect a TCP socket to port 2049, with no preceding =20
>>> rpcbind
>>> request.
>>>
>>> Carlos, let us know if you have replaced any NFS-related CentOS =20
>>> components
>>> (kernel, nfs-utils) with something you've built yourself.
>>>
>>>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>>>
>>>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>>>
>>>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail.com> =20
>>>>>> wrote:
>>>>>>>
>>>>>>> Anyone ?
>>>>>>>
>>>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>>>
>>>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work =20
>>>>>>>> with
>>>>>>>> Kerberos
>>>>>>>> and AutoFS, but i got a problem: If NFS server goes down i =20
>>>>>>>> get a
>>>>>>>> LOOOOOOONG
>>>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>>>
>>>>>>>> Since i need mount some (3 to 6) dirs at user logon process, =20
>>>>>>>> if mount
>>>>>>>> hangs,
>>>>>>>> user logon hangs. Then i want configure it to timeout (if =20
>>>>>>>> server down)
>>>>>>>> after
>>>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>>>
>>>>>>>> I already make a lab and tried a LOT of combinations, there my
>>>>>>>> findings
>>>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using =20
>>>>>>>> basic
>>>>>>>> command
>>>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>>>
>>>>>>>> - Once i try access mount point using AutoFS (proto=3Dtcp OR =20
>>>>>>>> proto=3Dudp)
>>>>>>>> it
>>>>>>>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error =20
>>>>>>>> (mount:
>>>>>>>> mount to
>>>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>>>
>>>>>> Sounds like you're hitting the server's grace period.
>>>>>
>>>>> I thought he was describing a situation where the server the =20
>>>>> server
>>>>> is completely gone and isn't coming back, and wondering how to =20
>>>>> make the
>>>>> mount fail faster.  But I may be misunderstanding.
>>>>>
>>>>> --b.
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-=20
>>>> nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
