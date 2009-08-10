From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Mon, 10 Aug 2009 16:43:16 -0300
Message-ID: <f6ce31e30908101243x1b69fdcbgdd8ae0d2d56e32de@mail.gmail.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	<f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
	<4A7BCCCA.4020307@panasas.com> <20090807140425.GA18298@fieldses.org>
	<f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
	<A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <A411E867-D130-4D82-89F0-5C73077EE475@oracle.com>
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

No, i'm just using packages from CentOS repo...

And u're right about expo retries... with tcpdump i've monitored
traffic and i got SYN retries in 3, 6, 12, 24, 48, 96 secs on port
2049...
I tried use "retry=3D1" option on mount without any change... I dont
want change source or tcp timers... just NFSv4 client.

2009/8/10 Chuck Lever <chuck.lever@oracle.com>:
> On Aug 10, 2009, at 2:29 PM, Carlos Andr=E9 wrote:
>>
>> Bruce, no... you're right. =A0I'm describing a situation where my server
>> died... i need mount fail faster (10 or 15 secs max) than 3 minutes
>> and 9 seconds...
>
> The 189 second timeout is likely how long it takes the kernel to give up
> trying to connect a TCP socket to the server (6 SYN attempts with
> exponential retries, or something like that). =A0For stock CentOS 5.3, I =
think
> user space does only a DNS lookup for normal NFSv4 mounts -- the kernel j=
ust
> tries to connect a TCP socket to port 2049, with no preceding rpcbind
> request.
>
> Carlos, let us know if you have replaced any NFS-related CentOS components
> (kernel, nfs-utils) with something you've built yourself.
>
>> 2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
>>>
>>> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>>>>
>>>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail.com> wrot=
e:
>>>>>
>>>>> Anyone ?
>>>>>
>>>>> 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>>>>>>
>>>>>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
>>>>>> Kerberos
>>>>>> and AutoFS, but i got a problem: If NFS server goes down i get a
>>>>>> LOOOOOOONG
>>>>>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>>>>>
>>>>>> Since i need mount some (3 to 6) dirs at user logon process, if mount
>>>>>> hangs,
>>>>>> user logon hangs. Then i want configure it to timeout (if server dow=
n)
>>>>>> after
>>>>>> 10-15 secs (MAX) on each mount attempt.
>>>>>>
>>>>>> I already make a lab and tried a LOT of combinations, there my
>>>>>> findings
>>>>>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using basic
>>>>>> command
>>>>>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>>>>>> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>>>>>>
>>>>>> - Once i try access mount point using AutoFS (proto=3Dtcp OR proto=
=3Dudp)
>>>>>> it
>>>>>> hangs for 189 secs (3m9s: real =A03m9.001s) =A0until show error (mou=
nt:
>>>>>> mount to
>>>>>> NFS server '172.16.0.10' failed: timed out (giving up))
>>>>
>>>> Sounds like you're hitting the server's grace period.
>>>
>>> I thought he was describing a situation where the server the server
>>> is completely gone and isn't coming back, and wondering how to make the
>>> mount fail faster. =A0But I may be misunderstanding.
>>>
>>> --b.
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
