From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: add a sysctl for disable the reconnect delay
Date: Wed, 14 Apr 2010 16:43:33 -0400
Message-ID: <C36646A2-70A4-4EF6-B34B-98F60D845BDE@oracle.com>
References: <4BA1FC54.9020209@cn.fujitsu.com> <4BA249BA.7000900@oracle.com> <4BC4469C.8000607@cn.fujitsu.com> <4BC48150.6020405@oracle.com> <4BC5993F.2040401@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=utf-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54038 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756740Ab0DNUoO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 16:44:14 -0400
In-Reply-To: <4BC5993F.2040401@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 14, 2010, at 6:30 AM, Mi Jinlong wrote:
> Chuck Lever =E5=86=99=E9=81=93:
>> On 04/13/2010 06:25 AM, Mi Jinlong wrote:
>>> Hi Chuck,
>>>=20
>>>   Sorry for replying your message so later.
>>>=20
>>> Chuck Lever =E5=86=99=E9=81=93:
>>>> Hi Mi-
>>>>=20
>>>> On 03/18/2010 06:11 AM, Mi Jinlong wrote:
>>>>> If network partition or some other reason cause a reconnect, it c=
annot
>>>>> succeed immediately when environment recover, but client want to
>>>>> connect
>>>>> timely sometimes.
>>>>>=20
>>>>> This patch can provide a proc
>>>>> file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
>>>>> to allow client disable the reconnect delay(reestablish_timeout) =
when
>>>>> using NFS.
>>>>>=20
>>>>> It's only useful for NFS.
>>>>=20
>>>> There's a good reason for the connection re-establishment delay, a=
nd
>>>> only very few instances where you'd want to disable it.  A sysctl =
is the
>>>> wrong place for this, as it would disable the reconnect delay acro=
ss the
>>>> board, instead of for just those occasions when it is actually nec=
essary
>>>> to connect immediately.
>>>=20
>>>   Yes, I agree with you.
>>>=20
>>>>=20
>>>> I assume that because the grace period has a time limit, you would=
 want
>>>> the client to reconnect at all costs?  I think that this is actual=
ly
>>>> when a client should take care not to spuriously reconnect: during=
 a
>>>> server reboot, a server may be sluggish or not completely ready to
>>>> accept client requests.  It's not a time when a client should be
>>>> showering a server with connection attempts.
>>>>=20
>>>> The reconnect delay is an exponential backoff that starts at 3 sec=
onds,
>>>> so if the server is really ready to accept connections, the actual
>>>> connection delay ought to be quick.
>>>>=20
>>>> We're already considering shortening the maximum amount of time th=
e
>>>> client can wait before trying a reconnect.  And, it might possibly=
 be
>>>> that the network layer itself is interfering with the backoff logi=
c that
>>>> is already built into the RPC client.  (If true, that would be the=
 real
>>>> bug in this case).  I'm not interested in a workaround when we rea=
lly
>>>> should fix any underlying issues to make this work correctly.
>>>>=20
>>>> Perhaps the RPC client needs to distinguish between connection ref=
usal
>>>> (where a lengthening exponential backoff between connection attemp=
ts
>>>> makes sense) and no server response (where we want the client's ne=
twork
>>>> layer to keep sending SYN requests so that it can reconnect as soo=
n as
>>>> possible).
>>>=20
>>>   When reading the kernel's code and testing, I find there are thre=
e
>>> case:
>>>=20
>>>   A. network partition:
>>>      Becasue the client can't communicate with server's rpcbind,
>>>      so there is no influence.
>>>=20
>>>   B. server's nfs service stop:
>>>      The client call xprt_connect to conncet, but get err(111:
>>> Connection refused).
>>>=20
>>>   C. server's nfs service sotp, and ifdown the NIC after about 60s:
>>>      At first, when the NIC is up, xprt_connect get err(111:
>>> Connection refused) as 2.
>>>=20
>>>      After NIC is down, xprt_connect get err(113: No route to host)=
=2E
>>>=20
>>>  When connecting fail, the sunrpc level only get a ETIMEDOUT or
>>> EAGAIN err, it will also
>>>  call xprt_connect to reconnect.
>>>  If we make the network layer to keep sending SYN requests, but the=
re
>>> will be more request
>>>  be delayed at the request queue, and the reestablish_timeout also =
be
>>> increased.
>>>=20
>>>  Can we distinguish those refusal at sunrpc level, but not at xprt
>>> level ?
>=20
>   What do you think that I show yesterday?

In xprtsock.c, these reconnection errors are distinguished.  In the gen=
eric sunrpc client (xprt.c) they are not -- when an RPC transmission is=
 sent, xprtsock.c returns ENOTCONN for any connection error.  Trond mad=
e this change after 2.6.18.  The differences matter in how the client r=
e-establishes the connection, and that logic is all in xprtsock.c.  So,=
 the RPC client already makes this distinction, but the logic may have =
bugs.

>>>  If we can do that, the problem will solved easily.
>>>=20
>>>  [NOTE]
>>>    the testing process:
>>>          client                    server
>>>    1.   mount nfs (OK)
>>>    2.     df (OK)
>>>    3.                             nfs stop
>>>    4.     df (hang)
>>>=20
>>>   I get message through rpcdebug.
>>=20
>> We have a matrix of cases.  "soft" v. "hard" RPCs, ECONNREFUSED v. n=
o
>> response, connection previously closed by server disconnect v. clien=
t
>> idle timeout.
>=20
>  connection previously closed by server disconnect v. client idle tim=
eout?
>  Can you explain to me in some sort? Maybe it's useful for me. Thanks=
=2E

If the server closed the connection, the client should use the re-estab=
lish timeout to delay the reconnection in order to prevent a hard loop =
of client connection retries.  If the client idled the connection out, =
then the client should reconnect immediately.

>> I've found at least one major bug in this logic, and that is that th=
e 60
>> second transport connect timer is clobbered in the ECONNREFUSED case=
, so
>> soft RPCs never time out if the server refuses a connection, for
>> example.  I handed all of this off to Trond.
>=20
>  Really?=20
>  I mount the nfs file through soft(-o soft), and then I using "df" co=
mmand
>  to see the mount information after server's nfs stop.
>  The "df" will return with error -5(Input/output error), maybe it's R=
PCs=20
>  timeout cause the df return?

RPC timeouts generally cause an EIO.  However, if the server continues =
to refuse a connection, the timeout never occurs.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



