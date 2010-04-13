From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] NFS: add a sysctl for disable the reconnect delay
Date: Tue, 13 Apr 2010 18:25:32 +0800
Message-ID: <4BC4469C.8000607@cn.fujitsu.com>
References: <4BA1FC54.9020209@cn.fujitsu.com> <4BA249BA.7000900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51826 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752273Ab0DMKXg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Apr 2010 06:23:36 -0400
In-Reply-To: <4BA249BA.7000900@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

  Sorry for replying your message so later.

Chuck Lever =E5=86=99=E9=81=93:
> Hi Mi-
>=20
> On 03/18/2010 06:11 AM, Mi Jinlong wrote:
>> If network partition or some other reason cause a reconnect, it cann=
ot
>> succeed immediately when environment recover, but client want to con=
nect
>> timely sometimes.
>>
>> This patch can provide a proc
>> file(/proc/sys/fs/nfs/nfs_disable_reconnect_delay)
>> to allow client disable the reconnect delay(reestablish_timeout) whe=
n
>> using NFS.
>>
>> It's only useful for NFS.
>=20
> There's a good reason for the connection re-establishment delay, and
> only very few instances where you'd want to disable it.  A sysctl is =
the
> wrong place for this, as it would disable the reconnect delay across =
the
> board, instead of for just those occasions when it is actually necess=
ary
> to connect immediately.

  Yes, I agree with you.

>=20
> I assume that because the grace period has a time limit, you would wa=
nt
> the client to reconnect at all costs?  I think that this is actually
> when a client should take care not to spuriously reconnect: during a
> server reboot, a server may be sluggish or not completely ready to
> accept client requests.  It's not a time when a client should be
> showering a server with connection attempts.
>=20
> The reconnect delay is an exponential backoff that starts at 3 second=
s,
> so if the server is really ready to accept connections, the actual
> connection delay ought to be quick.
>=20
> We're already considering shortening the maximum amount of time the
> client can wait before trying a reconnect.  And, it might possibly be
> that the network layer itself is interfering with the backoff logic t=
hat
> is already built into the RPC client.  (If true, that would be the re=
al
> bug in this case).  I'm not interested in a workaround when we really
> should fix any underlying issues to make this work correctly.
>=20
> Perhaps the RPC client needs to distinguish between connection refusa=
l
> (where a lengthening exponential backoff between connection attempts
> makes sense) and no server response (where we want the client's netwo=
rk
> layer to keep sending SYN requests so that it can reconnect as soon a=
s
> possible).

  When reading the kernel's code and testing, I find there are three ca=
se:

  A. network partition:
     Becasue the client can't communicate with server's rpcbind,=20
     so there is no influence.

  B. server's nfs service stop:
     The client call xprt_connect to conncet, but get err(111: Connecti=
on refused).

  C. server's nfs service sotp, and ifdown the NIC after about 60s:
     At first, when the NIC is up, xprt_connect get err(111: Connection=
 refused) as 2.

     After NIC is down, xprt_connect get err(113: No route to host).

 When connecting fail, the sunrpc level only get a ETIMEDOUT or EAGAIN =
err, it will also
 call xprt_connect to reconnect.
 If we make the network layer to keep sending SYN requests, but there w=
ill be more request=20
 be delayed at the request queue, and the reestablish_timeout also be i=
ncreased.

 Can we distinguish those refusal at sunrpc level, but not at xprt leve=
l ?
 If we can do that, the problem will solved easily.
 =20
 [NOTE]
   the testing process:
         client                    server
   1.   mount nfs (OK)=20
   2.     df (OK)
   3.                             nfs stop
   4.     df (hang)

  I get message through rpcdebug.

>=20
> The second scenario might disable the reconnect timer so that only on=
e
> ->connect() call would be outstanding until the network layer tells u=
s
> it's given up on SYN retries.
 =20
  I think that's a good idea, but implementation may be a great work.
 =20
thanks,
Mi Jinlong

