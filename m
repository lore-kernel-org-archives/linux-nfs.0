From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] NFS: add a sysctl for disable the reconnect delay
Date: Wed, 14 Apr 2010 18:30:23 +0800
Message-ID: <4BC5993F.2040401@cn.fujitsu.com>
References: <4BA1FC54.9020209@cn.fujitsu.com> <4BA249BA.7000900@oracle.com> <4BC4469C.8000607@cn.fujitsu.com> <4BC48150.6020405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50687 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754328Ab0DNK2W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 06:28:22 -0400
In-Reply-To: <4BC48150.6020405@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever =E5=86=99=E9=81=93:
> On 04/13/2010 06:25 AM, Mi Jinlong wrote:
>> Hi Chuck,
>>
>>    Sorry for replying your message so later.
>>
>> Chuck Lever =E5=86=99=E9=81=93:
>>> Hi Mi-
>>>
>>> On 03/18/2010 06:11 AM, Mi Jinlong wrote:
>>>> If network partition or some other reason cause a reconnect, it ca=
nnot
>>>> succeed immediately when environment recover, but client want to
>>>> connect
>>>> timely sometimes.
>>>>
>>>> This patch can provide a proc
>>>> file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
>>>> to allow client disable the reconnect delay(reestablish_timeout) w=
hen
>>>> using NFS.
>>>>
>>>> It's only useful for NFS.
>>>
>>> There's a good reason for the connection re-establishment delay, an=
d
>>> only very few instances where you'd want to disable it.  A sysctl i=
s the
>>> wrong place for this, as it would disable the reconnect delay acros=
s the
>>> board, instead of for just those occasions when it is actually nece=
ssary
>>> to connect immediately.
>>
>>    Yes, I agree with you.
>>
>>>
>>> I assume that because the grace period has a time limit, you would =
want
>>> the client to reconnect at all costs?  I think that this is actuall=
y
>>> when a client should take care not to spuriously reconnect: during =
a
>>> server reboot, a server may be sluggish or not completely ready to
>>> accept client requests.  It's not a time when a client should be
>>> showering a server with connection attempts.
>>>
>>> The reconnect delay is an exponential backoff that starts at 3 seco=
nds,
>>> so if the server is really ready to accept connections, the actual
>>> connection delay ought to be quick.
>>>
>>> We're already considering shortening the maximum amount of time the
>>> client can wait before trying a reconnect.  And, it might possibly =
be
>>> that the network layer itself is interfering with the backoff logic=
 that
>>> is already built into the RPC client.  (If true, that would be the =
real
>>> bug in this case).  I'm not interested in a workaround when we real=
ly
>>> should fix any underlying issues to make this work correctly.
>>>
>>> Perhaps the RPC client needs to distinguish between connection refu=
sal
>>> (where a lengthening exponential backoff between connection attempt=
s
>>> makes sense) and no server response (where we want the client's net=
work
>>> layer to keep sending SYN requests so that it can reconnect as soon=
 as
>>> possible).
>>
>>    When reading the kernel's code and testing, I find there are thre=
e
>> case:
>>
>>    A. network partition:
>>       Becasue the client can't communicate with server's rpcbind,
>>       so there is no influence.
>>
>>    B. server's nfs service stop:
>>       The client call xprt_connect to conncet, but get err(111:
>> Connection refused).
>>
>>    C. server's nfs service sotp, and ifdown the NIC after about 60s:
>>       At first, when the NIC is up, xprt_connect get err(111:
>> Connection refused) as 2.
>>
>>       After NIC is down, xprt_connect get err(113: No route to host)=
=2E
>>
>>   When connecting fail, the sunrpc level only get a ETIMEDOUT or
>> EAGAIN err, it will also
>>   call xprt_connect to reconnect.
>>   If we make the network layer to keep sending SYN requests, but the=
re
>> will be more request
>>   be delayed at the request queue, and the reestablish_timeout also =
be
>> increased.
>>
>>   Can we distinguish those refusal at sunrpc level, but not at xprt
>> level ?

   What do you think that I show yesterday?

>>   If we can do that, the problem will solved easily.
>>
>>   [NOTE]
>>     the testing process:
>>           client                    server
>>     1.   mount nfs (OK)
>>     2.     df (OK)
>>     3.                             nfs stop
>>     4.     df (hang)
>>
>>    I get message through rpcdebug.
>=20
> We have a matrix of cases.  "soft" v. "hard" RPCs, ECONNREFUSED v. no
> response, connection previously closed by server disconnect v. client
> idle timeout.

  connection previously closed by server disconnect v. client idle time=
out?
  Can you explain to me in some sort? Maybe it's useful for me. Thanks.

>=20
> I've found at least one major bug in this logic, and that is that the=
 60
> second transport connect timer is clobbered in the ECONNREFUSED case,=
 so
> soft RPCs never time out if the server refuses a connection, for
> example.  I handed all of this off to Trond.

  Really?=20
  I mount the nfs file through soft(-o soft), and then I using "df" com=
mand
  to see the mount information after server's nfs stop.
  The "df" will return with error -5(Input/output error), maybe it's RP=
Cs=20
  timeout cause the df return?

thanks,
Mi Jinlong

