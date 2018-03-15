Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:38822 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbeCOAyI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2018 20:54:08 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 07/15] sunrpc: Save remote presentation address in
 svc_xprt for trace events
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180314203506.GA7241@fieldses.org>
Date: Wed, 14 Mar 2018 20:54:01 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3CA64950-7DC9-418B-8E26-E454A32888AC@oracle.com>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154416.21531.66413.stgit@klimt.1015granger.net>
 <20180314203506.GA7241@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 14, 2018, at 4:35 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Tue, Mar 13, 2018 at 11:44:16AM -0400, Chuck Lever wrote:
>> TP_printk defines a format string that is passed to user space for
>> converting raw trace event records to something human-readable.
>>=20
>> My user space's printf (Oracle Linux 7), however, does not have a
>> %pI format specifier. The result is that what is supposed to be an
>> IP address in the output of "trace-cmd report" is just a string that
>> says the field couldn't be displayed.
>>=20
>> To fix this, adopt the same approach as the client: maintain a pre-
>> formated presentation address for occasions when %pI is not
>> available.
>>=20
>> The location of the trace_svc_send trace point is adjusted so that
>> rqst->rq_xprt is not NULL when the trace event is recorded.
>=20
> So presumably the problem could also be fixed in userspace; why is it
> better to do it here?

"User space" means the C library's printf() implementation. You'd have
to address this by adding %pI to every possible C library used by Linux
distributions.

Also, as mentioned above, we've already used this approach successfully
in several other similar places.


> --b.
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/svc_xprt.h          |    4 +
>> include/trace/events/sunrpc.h            |   89 =
+++++++++++-------------------
>> net/sunrpc/svc_xprt.c                    |    3 +
>> net/sunrpc/svcsock.c                     |    1=20
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 +
>> 5 files changed, 43 insertions(+), 58 deletions(-)
>>=20
>> diff --git a/include/linux/sunrpc/svc_xprt.h =
b/include/linux/sunrpc/svc_xprt.h
>> index 19475ac..c3d7206 100644
>> --- a/include/linux/sunrpc/svc_xprt.h
>> +++ b/include/linux/sunrpc/svc_xprt.h
>> @@ -83,6 +83,7 @@ struct svc_xprt {
>> 	size_t			xpt_locallen;	/* length of address */
>> 	struct sockaddr_storage	xpt_remote;	/* remote peer's address =
*/
>> 	size_t			xpt_remotelen;	/* length of address */
>> +	char			xpt_remotebuf[INET6_ADDRSTRLEN + 10];
>> 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait =
queue */
>> 	struct list_head	xpt_users;	/* callbacks on free */
>>=20
>> @@ -152,7 +153,10 @@ static inline void svc_xprt_set_remote(struct =
svc_xprt *xprt,
>> {
>> 	memcpy(&xprt->xpt_remote, sa, salen);
>> 	xprt->xpt_remotelen =3D salen;
>> +	snprintf(xprt->xpt_remotebuf, sizeof(xprt->xpt_remotebuf) - 1,
>> +		 "%pISpc", sa);
>> }
>> +
>> static inline unsigned short svc_addr_port(const struct sockaddr *sa)
>> {
>> 	const struct sockaddr_in *sin =3D (const struct sockaddr_in =
*)sa;
>> diff --git a/include/trace/events/sunrpc.h =
b/include/trace/events/sunrpc.h
>> index 5849bfb..1ec8c4c 100644
>> --- a/include/trace/events/sunrpc.h
>> +++ b/include/trace/events/sunrpc.h
>> @@ -493,20 +493,18 @@
>> 		__field(u32, xid)
>> 		__field(int, len)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
>> +		__string(addr, rqst->rq_xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xid =3D be32_to_cpu(rqst->rq_xid);
>> 		__entry->len =3D len;
>> 		__entry->flags =3D rqst->rq_flags;
>> -		memcpy(__get_dynamic_array(addr),
>> -			&rqst->rq_addr, rqst->rq_addrlen);
>> +		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("addr=3D%pIScp xid=3D0x%08x len=3D%d flags=3D%s",
>> -			(struct sockaddr *)__get_dynamic_array(addr),
>> -			__entry->xid, __entry->len,
>> +	TP_printk("addr=3D%s xid=3D0x%08x len=3D%d flags=3D%s",
>> +			__get_str(addr), __entry->xid, __entry->len,
>> 			show_rqstp_flags(__entry->flags))
>> );
>>=20
>> @@ -519,20 +517,18 @@
>> 	TP_STRUCT__entry(
>> 		__field(u32, xid)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
>> +		__string(addr, rqst->rq_xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xid =3D be32_to_cpu(rqst->rq_xid);
>> 		__entry->flags =3D rqst->rq_flags;
>> -		memcpy(__get_dynamic_array(addr),
>> -			&rqst->rq_addr, rqst->rq_addrlen);
>> +		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("addr=3D%pIScp rq_xid=3D0x%08x flags=3D%s",
>> -		(struct sockaddr *)__get_dynamic_array(addr),
>> -		__entry->xid,
>> -		show_rqstp_flags(__entry->flags))
>> +	TP_printk("addr=3D%s xid=3D0x%08x flags=3D%s",
>> +			__get_str(addr), __entry->xid,
>> +			show_rqstp_flags(__entry->flags))
>> );
>>=20
>> DEFINE_EVENT(svc_rqst_event, svc_defer,
>> @@ -553,21 +549,19 @@
>> 		__field(u32, xid)
>> 		__field(int, status)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, rqst->rq_addrlen)
>> +		__string(addr, rqst->rq_xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xid =3D be32_to_cpu(rqst->rq_xid);
>> 		__entry->status =3D status;
>> 		__entry->flags =3D rqst->rq_flags;
>> -		memcpy(__get_dynamic_array(addr),
>> -			&rqst->rq_addr, rqst->rq_addrlen);
>> +		__assign_str(addr, rqst->rq_xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("addr=3D%pIScp rq_xid=3D0x%08x status=3D%d flags=3D%s",
>> -		(struct sockaddr *)__get_dynamic_array(addr),
>> -		__entry->xid,
>> -		__entry->status, show_rqstp_flags(__entry->flags))
>> +	TP_printk("addr=3D%s xid=3D0x%08x status=3D%d flags=3D%s",
>> +		  __get_str(addr), __entry->xid,
>> +		  __entry->status, show_rqstp_flags(__entry->flags))
>> );
>>=20
>> DEFINE_EVENT(svc_rqst_status, svc_process,
>> @@ -604,26 +598,19 @@
>> 		__field(struct svc_xprt *, xprt)
>> 		__field(int, pid)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, xprt !=3D NULL ?
>> -			xprt->xpt_remotelen : 0)
>> +		__string(addr, xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xprt =3D xprt;
>> 		__entry->pid =3D rqst? rqst->rq_task->pid : 0;
>> -		if (xprt) {
>> -			memcpy(__get_dynamic_array(addr),
>> -				&xprt->xpt_remote,
>> -				xprt->xpt_remotelen);
>> -			__entry->flags =3D xprt->xpt_flags;
>> -		} else
>> -			__entry->flags =3D 0;
>> +		__entry->flags =3D xprt->xpt_flags;
>> +		__assign_str(addr, xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("xprt=3D0x%p addr=3D%pIScp pid=3D%d flags=3D%s", =
__entry->xprt,
>> -		__get_dynamic_array_len(addr) !=3D 0 ?
>> -			(struct sockaddr *)__get_dynamic_array(addr) : =
NULL,
>> -		__entry->pid, show_svc_xprt_flags(__entry->flags))
>> +	TP_printk("xprt=3D%p addr=3D%s pid=3D%d flags=3D%s",
>> +			__entry->xprt, __get_str(addr),
>> +			__entry->pid, =
show_svc_xprt_flags(__entry->flags))
>> );
>>=20
>> DECLARE_EVENT_CLASS(svc_xprt_event,
>> @@ -634,19 +621,18 @@
>> 	TP_STRUCT__entry(
>> 		__field(struct svc_xprt *, xprt)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, =
xprt->xpt_remotelen)
>> +		__string(addr, xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xprt =3D xprt;
>> 		__entry->flags =3D xprt->xpt_flags;
>> -		memcpy(__get_dynamic_array(addr),
>> -		       &xprt->xpt_remote, xprt->xpt_remotelen);
>> +		__assign_str(addr, xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("xprt=3D0x%p addr=3D%pIScp flags=3D%s", __entry->xprt,
>> -		(struct sockaddr *)__get_dynamic_array(addr),
>> -		show_svc_xprt_flags(__entry->flags))
>> +	TP_printk("xprt=3D%p addr=3D%s flags=3D%s",
>> +			__entry->xprt, __get_str(addr),
>> +			show_svc_xprt_flags(__entry->flags))
>> );
>>=20
>> DEFINE_EVENT(svc_xprt_event, svc_xprt_dequeue,
>> @@ -682,25 +668,18 @@
>> 		__field(struct svc_xprt *, xprt)
>> 		__field(int, len)
>> 		__field(unsigned long, flags)
>> -		__dynamic_array(unsigned char, addr, xprt !=3D NULL ?
>> -			xprt->xpt_remotelen : 0)
>> +		__string(addr, xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xprt =3D xprt;
>> 		__entry->len =3D len;
>> -		if (xprt) {
>> -			memcpy(__get_dynamic_array(addr),
>> -					&xprt->xpt_remote,
>> -					xprt->xpt_remotelen);
>> -			__entry->flags =3D xprt->xpt_flags;
>> -		} else
>> -			__entry->flags =3D 0;
>> +		__entry->flags =3D xprt->xpt_flags;
>> +		__assign_str(addr, xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("xprt=3D0x%p addr=3D%pIScp len=3D%d flags=3D%s", =
__entry->xprt,
>> -		__get_dynamic_array_len(addr) !=3D 0 ?
>> -			(struct sockaddr *)__get_dynamic_array(addr) : =
NULL,
>> +	TP_printk("xprt=3D%p addr=3D%s len=3D%d flags=3D%s",
>> +		__entry->xprt, __get_str(addr),
>> 		__entry->len, show_svc_xprt_flags(__entry->flags))
>> );
>>=20
>> @@ -712,18 +691,16 @@
>>=20
>> 	TP_STRUCT__entry(
>> 		__field(u32, xid)
>> -		__dynamic_array(unsigned char, addr, dr->addrlen)
>> +		__string(addr, dr->xprt->xpt_remotebuf)
>> 	),
>>=20
>> 	TP_fast_assign(
>> 		__entry->xid =3D be32_to_cpu(*(__be32 *)(dr->args +
>> 						       =
(dr->xprt_hlen>>2)));
>> -		memcpy(__get_dynamic_array(addr), &dr->addr, =
dr->addrlen);
>> +		__assign_str(addr, dr->xprt->xpt_remotebuf);
>> 	),
>>=20
>> -	TP_printk("addr=3D%pIScp xid=3D0x%08x",
>> -		(struct sockaddr *)__get_dynamic_array(addr),
>> -		__entry->xid)
>> +	TP_printk("addr=3D%s xid=3D0x%08x", __get_str(addr), =
__entry->xid)
>> );
>>=20
>> DEFINE_EVENT(svc_deferred_event, svc_drop_deferred,
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 47384d0..f745754 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -173,6 +173,7 @@ void svc_xprt_init(struct net *net, struct =
svc_xprt_class *xcl,
>> 	set_bit(XPT_BUSY, &xprt->xpt_flags);
>> 	rpc_init_wait_queue(&xprt->xpt_bc_pending, "xpt_bc_pending");
>> 	xprt->xpt_net =3D get_net(net);
>> +	strcpy(xprt->xpt_remotebuf, "uninitialized");
>> }
>> EXPORT_SYMBOL_GPL(svc_xprt_init);
>>=20
>> @@ -894,12 +895,12 @@ int svc_send(struct svc_rqst *rqstp)
>> 		len =3D xprt->xpt_ops->xpo_sendto(rqstp);
>> 	mutex_unlock(&xprt->xpt_mutex);
>> 	rpc_wake_up(&xprt->xpt_bc_pending);
>> +	trace_svc_send(rqstp, len);
>> 	svc_xprt_release(rqstp);
>>=20
>> 	if (len =3D=3D -ECONNREFUSED || len =3D=3D -ENOTCONN || len =3D=3D=
 -EAGAIN)
>> 		len =3D 0;
>> out:
>> -	trace_svc_send(rqstp, len);
>> 	return len;
>> }
>>=20
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index 9b67035..4ca1d92 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -1310,6 +1310,7 @@ static void svc_tcp_init(struct svc_sock *svsk, =
struct svc_serv *serv)
>> 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>> 	if (sk->sk_state =3D=3D TCP_LISTEN) {
>> 		dprintk("setting up TCP socket for listening\n");
>> +		strcpy(svsk->sk_xprt.xpt_remotebuf, "listener");
>> 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
>> 		sk->sk_data_ready =3D svc_tcp_listen_data_ready;
>> 		set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c =
b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index b083ac8..ca211dc 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -401,8 +401,10 @@ static struct svcxprt_rdma =
*rdma_create_xprt(struct svc_serv *serv,
>> 	 */
>> 	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
>>=20
>> -	if (listener)
>> +	if (listener) {
>> +		strcpy(cma_xprt->sc_xprt.xpt_remotebuf, "listener");
>> 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
>> +	}
>>=20
>> 	return cma_xprt;
>> }

--
Chuck Lever



