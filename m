From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: add a sysctl for disable the reconnect delay
Date: Tue, 13 Apr 2010 10:36:00 -0400
Message-ID: <4BC48150.6020405@oracle.com>
References: <4BA1FC54.9020209@cn.fujitsu.com> <4BA249BA.7000900@oracle.com> <4BC4469C.8000607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:45364 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249Ab0DMOiE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Apr 2010 10:38:04 -0400
In-Reply-To: <4BC4469C.8000607@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/13/2010 06:25 AM, Mi Jinlong wrote:
> Hi Chuck,
>
>    Sorry for replying your message so later.
>
> Chuck Lever =E5=86=99=E9=81=93:
>> Hi Mi-
>>
>> On 03/18/2010 06:11 AM, Mi Jinlong wrote:
>>> If network partition or some other reason cause a reconnect, it can=
not
>>> succeed immediately when environment recover, but client want to co=
nnect
>>> timely sometimes.
>>>
>>> This patch can provide a proc
>>> file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
>>> to allow client disable the reconnect delay(reestablish_timeout) wh=
en
>>> using NFS.
>>>
>>> It's only useful for NFS.
>>
>> There's a good reason for the connection re-establishment delay, and
>> only very few instances where you'd want to disable it.  A sysctl is=
 the
>> wrong place for this, as it would disable the reconnect delay across=
 the
>> board, instead of for just those occasions when it is actually neces=
sary
>> to connect immediately.
>
>    Yes, I agree with you.
>
>>
>> I assume that because the grace period has a time limit, you would w=
ant
>> the client to reconnect at all costs?  I think that this is actually
>> when a client should take care not to spuriously reconnect: during a
>> server reboot, a server may be sluggish or not completely ready to
>> accept client requests.  It's not a time when a client should be
>> showering a server with connection attempts.
>>
>> The reconnect delay is an exponential backoff that starts at 3 secon=
ds,
>> so if the server is really ready to accept connections, the actual
>> connection delay ought to be quick.
>>
>> We're already considering shortening the maximum amount of time the
>> client can wait before trying a reconnect.  And, it might possibly b=
e
>> that the network layer itself is interfering with the backoff logic =
that
>> is already built into the RPC client.  (If true, that would be the r=
eal
>> bug in this case).  I'm not interested in a workaround when we reall=
y
>> should fix any underlying issues to make this work correctly.
>>
>> Perhaps the RPC client needs to distinguish between connection refus=
al
>> (where a lengthening exponential backoff between connection attempts
>> makes sense) and no server response (where we want the client's netw=
ork
>> layer to keep sending SYN requests so that it can reconnect as soon =
as
>> possible).
>
>    When reading the kernel's code and testing, I find there are three=
 case:
>
>    A. network partition:
>       Becasue the client can't communicate with server's rpcbind,
>       so there is no influence.
>
>    B. server's nfs service stop:
>       The client call xprt_connect to conncet, but get err(111: Conne=
ction refused).
>
>    C. server's nfs service sotp, and ifdown the NIC after about 60s:
>       At first, when the NIC is up, xprt_connect get err(111: Connect=
ion refused) as 2.
>
>       After NIC is down, xprt_connect get err(113: No route to host).
>
>   When connecting fail, the sunrpc level only get a ETIMEDOUT or EAGA=
IN err, it will also
>   call xprt_connect to reconnect.
>   If we make the network layer to keep sending SYN requests, but ther=
e will be more request
>   be delayed at the request queue, and the reestablish_timeout also b=
e increased.
>
>   Can we distinguish those refusal at sunrpc level, but not at xprt l=
evel ?
>   If we can do that, the problem will solved easily.
>
>   [NOTE]
>     the testing process:
>           client                    server
>     1.   mount nfs (OK)
>     2.     df (OK)
>     3.                             nfs stop
>     4.     df (hang)
>
>    I get message through rpcdebug.

We have a matrix of cases.  "soft" v. "hard" RPCs, ECONNREFUSED v. no=20
response, connection previously closed by server disconnect v. client=20
idle timeout.

I've found at least one major bug in this logic, and that is that the 6=
0=20
second transport connect timer is clobbered in the ECONNREFUSED case, s=
o=20
soft RPCs never time out if the server refuses a connection, for=20
example.  I handed all of this off to Trond.

>> The second scenario might disable the reconnect timer so that only o=
ne
>> ->connect() call would be outstanding until the network layer tells =
us
>> it's given up on SYN retries.
>
>    I think that's a good idea, but implementation may be a great work=
=2E
>
> thanks,
> Mi Jinlong
>


--=20
chuck[dot]lever[at]oracle[dot]com
