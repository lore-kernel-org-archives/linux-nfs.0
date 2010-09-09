From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] sunrpc: cancel delayed connect working when conncet success
Date: Thu, 09 Sep 2010 18:11:17 +0800
Message-ID: <4C88B2C5.5040100@cn.fujitsu.com>
References: <4C6BACAA.2060706@cn.fujitsu.com> <1283195927.2920.3.camel@heimdal.trondhjem.org> <4C7C5124.1060000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64187 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754314Ab0IIKJL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 06:09:11 -0400
In-Reply-To: <4C7C5124.1060000@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

  what do you think about this problem ?

thanks,
Mi Jinlong

Mi Jinlong =E5=86=99=E9=81=93:
> Hi Trond,
>=20
> Trond Myklebust =E5=86=99=E9=81=93:
>> On Wed, 2010-08-18 at 17:49 +0800, Mi Jinlong wrote:
>>> As network partition or some other reason, when client connect=20
>>> success, maybe there is some delayed connect working in connect_wor=
k list.
>>>
>>> Aug  2 12:51:32 TEST-M kernel: RPC:       xs_connect delayed xprt c=
cc4c800 for 96 seconds
>>> Aug  2 12:51:32 TEST-M kernel: RPC:       xs_error_report client cc=
c4c800...
>>> Aug  2 12:51:32 TEST-M kernel: RPC:       error 111
>>>  ... snip ...
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       disconnected transport cc=
c4c800
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       worker connecting xprt cc=
c4c800 via tcp to 192.168.0.21 (port 2049)
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       ccc4c800 connect status 1=
15 connected 0 sock state 2
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: retr=
ying
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_prepare_transmit
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_transmit(136)
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_send_request(136) =
=3D -11
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit incomplete (136 left=
 of 136)
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect xprt ccc4c80=
0 is not connected
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_connect delayed xprt c=
cc4c800 for 192 seconds
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_state_change clien=
t ccc4c800...
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       state 1 conn 0 dead 0 zap=
ped 1
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: retr=
ying
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_prepare_transmit
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_transmit(136)
>>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_send_request(136) =
=3D 136
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit complete
>>> Aug  2 12:53:08 TEST-M kernel: RPC:   229 xprt_prepare_transmit
>>>
>>> As the debug message show, "xs_connect delayed xprt ccc4c800 for 19=
2 seconds"
>>> means a connecting work have be delayed at connect_worker list.
>>> "state 1 conn 0 dead 0 zapped 1" shows the connect have successed=20
>>> but a delayed work still alive at connect_worker list.
>>>
>>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>>>
>>> ---
>>>  net/sunrpc/xprtsock.c |    4 ++++
>>>  1 files changed, 4 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 49a62f0..823f1db 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -1324,6 +1324,10 @@ static void xs_tcp_state_change(struct sock =
*sk)
>>>  			transport->tcp_flags =3D
>>>  				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
>>> =20
>>> +			if (xprt_connecting(xprt) &&
>>> +			      cancel_delayed_work(&transport->connect_worker))
>>> +				xprt_clear_connecting(xprt);
>>> +
>>>  			xprt_wake_pending_tasks(xprt, -EAGAIN);
>>>  		}
>>>  		spin_unlock_bh(&xprt->transport_lock);
>> Wait... According to the above trace, the connect request is _failin=
g_
>> due to an ECONNREFUSED error. In that case, we _want_ to delay the
>> reconnection in order to give the server time to set itself up.
>=20
>   Yes, that's right.
>=20
>   But, the important part of the trace is=20
>   "
>    Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit incomplete (136 lef=
t of 136)
>    Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect xprt ccc4c8=
00 is not connected
>    Aug  2 12:53:08 TEST-M kernel: RPC:       xs_connect delayed xprt =
ccc4c800 for 192 seconds
>    Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_state_change clie=
nt ccc4c800...
>    Aug  2 12:53:08 TEST-M kernel: RPC:       state 1 conn 0 dead 0 za=
pped 1
>    Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: ret=
rying
>   ".
>=20
>   The SUNRPC's TCP connecting is asynchronous, but the tcp_connect()
>   only send a SYN but don't waiting for the ACK reply.
>=20
>     CLIENT                                   SERVER
>=20
>   1. The first connecting
>=20
>     |-xs_connect()
>      |-kernel_connect(O_NONBLOCK)
>        |-tcp_connet()  -------- SYN --------->
>=20
>    xs_connect() return with EINPROGRESS and the ACK have not reply.=20
>=20
>   2. a reconnecting of 1
>     |-xs_connect()
>         queue_delayed_work(rpciod_workqueue,
>                             &transport->connect_worker,
>                             xprt->reestablish_timeout);
>=20
>               <---------------ACK SYN--------------
>=20
>    After the reconnecting have put the connect working to connect_wor=
ker,
>    the ACK-SYN for the first connecting reply, the connect is OK now.
>=20
> At this instance, a delayed connect working will be exist at connect_=
worker
> after connecting success, we should cancel this working.
>=20
> thanks,
> Mi Jinlong
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

