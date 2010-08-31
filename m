Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54503 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755817Ab0HaApi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 20:45:38 -0400
Message-ID: <4C7C5124.1060000@cn.fujitsu.com>
Date: Tue, 31 Aug 2010 08:47:32 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: NFSv3 list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: cancel delayed connect working when conncet success
References: <4C6BACAA.2060706@cn.fujitsu.com> <1283195927.2920.3.camel@heimdal.trondhjem.org>
In-Reply-To: <1283195927.2920.3.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

Trond Myklebust 写道:
> On Wed, 2010-08-18 at 17:49 +0800, Mi Jinlong wrote:
>> As network partition or some other reason, when client connect 
>> success, maybe there is some delayed connect working in connect_work list.
>>
>> Aug  2 12:51:32 TEST-M kernel: RPC:       xs_connect delayed xprt ccc4c800 for 96 seconds
>> Aug  2 12:51:32 TEST-M kernel: RPC:       xs_error_report client ccc4c800...
>> Aug  2 12:51:32 TEST-M kernel: RPC:       error 111
>>  ... snip ...
>> Aug  2 12:53:08 TEST-M kernel: RPC:       disconnected transport ccc4c800
>> Aug  2 12:53:08 TEST-M kernel: RPC:       worker connecting xprt ccc4c800 via tcp to 192.168.0.21 (port 2049)
>> Aug  2 12:53:08 TEST-M kernel: RPC:       ccc4c800 connect status 115 connected 0 sock state 2
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: retrying
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_prepare_transmit
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_transmit(136)
>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_send_request(136) = -11
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit incomplete (136 left of 136)
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect xprt ccc4c800 is not connected
>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_connect delayed xprt ccc4c800 for 192 seconds
>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_state_change client ccc4c800...
>> Aug  2 12:53:08 TEST-M kernel: RPC:       state 1 conn 0 dead 0 zapped 1
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: retrying
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_prepare_transmit
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_transmit(136)
>> Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_send_request(136) = 136
>> Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit complete
>> Aug  2 12:53:08 TEST-M kernel: RPC:   229 xprt_prepare_transmit
>>
>> As the debug message show, "xs_connect delayed xprt ccc4c800 for 192 seconds"
>> means a connecting work have be delayed at connect_worker list.
>> "state 1 conn 0 dead 0 zapped 1" shows the connect have successed 
>> but a delayed work still alive at connect_worker list.
>>
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>>
>> ---
>>  net/sunrpc/xprtsock.c |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 49a62f0..823f1db 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1324,6 +1324,10 @@ static void xs_tcp_state_change(struct sock *sk)
>>  			transport->tcp_flags =
>>  				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
>>  
>> +			if (xprt_connecting(xprt) &&
>> +			      cancel_delayed_work(&transport->connect_worker))
>> +				xprt_clear_connecting(xprt);
>> +
>>  			xprt_wake_pending_tasks(xprt, -EAGAIN);
>>  		}
>>  		spin_unlock_bh(&xprt->transport_lock);
> 
> Wait... According to the above trace, the connect request is _failing_
> due to an ECONNREFUSED error. In that case, we _want_ to delay the
> reconnection in order to give the server time to set itself up.

  Yes, that's right.

  But, the important part of the trace is 
  "
   Aug  2 12:53:08 TEST-M kernel: RPC:   228 xmit incomplete (136 left of 136)
   Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect xprt ccc4c800 is not connected
   Aug  2 12:53:08 TEST-M kernel: RPC:       xs_connect delayed xprt ccc4c800 for 192 seconds
   Aug  2 12:53:08 TEST-M kernel: RPC:       xs_tcp_state_change client ccc4c800...
   Aug  2 12:53:08 TEST-M kernel: RPC:       state 1 conn 0 dead 0 zapped 1
   Aug  2 12:53:08 TEST-M kernel: RPC:   228 xprt_connect_status: retrying
  ".

  The SUNRPC's TCP connecting is asynchronous, but the tcp_connect()
  only send a SYN but don't waiting for the ACK reply.

    CLIENT                                   SERVER

  1. The first connecting

    |-xs_connect()
     |-kernel_connect(O_NONBLOCK)
       |-tcp_connet()  -------- SYN --------->

   xs_connect() return with EINPROGRESS and the ACK have not reply. 

  2. a reconnecting of 1
    |-xs_connect()
        queue_delayed_work(rpciod_workqueue,
                            &transport->connect_worker,
                            xprt->reestablish_timeout);

              <---------------ACK SYN--------------

   After the reconnecting have put the connect working to connect_worker,
   the ACK-SYN for the first connecting reply, the connect is OK now.

At this instance, a delayed connect working will be exist at connect_worker
after connecting success, we should cancel this working.

thanks,
Mi Jinlong

