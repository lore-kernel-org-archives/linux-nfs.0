From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 7 Jul 2008 21:56:29 -0400
Message-ID: <76bd70e30807071856i2aaf74a9w5c207b6929746a56@mail.gmail.com>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
	 <20080703204543.GI30918@fieldses.org>
	 <1215454820.19512.25.camel@localhost>
	 <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com>
	 <1215456693.19512.36.camel@localhost>
	 <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com>
	 <1215463877.19512.40.camel@localhost>
	 <20080707211925.GB19523@fieldses.org>
	 <1215468822.19512.55.camel@localhost>
	 <20080707225647.GJ19523@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:3893 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789AbYGHB4b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2008 21:56:31 -0400
Received: by gv-out-0910.google.com with SMTP id e6so380928gvc.37
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2008 18:56:30 -0700 (PDT)
In-Reply-To: <20080707225647.GJ19523@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 7, 2008 at 6:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jul 07, 2008 at 06:13:42PM -0400, Trond Myklebust wrote:
>> On Mon, 2008-07-07 at 17:19 -0400, J. Bruce Fields wrote:
>> > On Mon, Jul 07, 2008 at 04:51:17PM -0400, Trond Myklebust wrote:
>> > > On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:
>> > >
>> > > > If you would like connected UDP, I won't object to you implementing
>> > > > it.  However, I never tested whether a connected UDP socket will give
>> > > > the desired semantics without extra code in the UDP transport (for
>> > > > example, an ->sk_error callback).  I don't think it's worth the hassle
>> > > > if we have to add code to UDP that only this tiny use case would need.
>> > > >
>> > >
>> > > OK. I'll set these patches aside until I have time to look into adding
>> > > connected UDP support.
>> >
>> > I'm curious--why weren't you convinced by this argument?:
>> >
>> >     "You're talking about the difference between supporting say 1358
>> >     mounts at boot time versus 1357 mounts at boot time.
>>
>> Where did you get those figures from?

It's just an example.

>> Firstly, the total number of
>> privileged ports is much smaller. Secondly, the number of _free_
>> privileged ports can vary wildly depending on the user's setup.

That's my point.  An admin could _maybe_ get one more NFS mount if she
disables a network service above port 665.  Are we going to stop users
from enabling non-NFS network services that might use an extra
privileged port?

The right way to fix this is to fix the way Linux does NFS mounts.  It
would be nice if we had a transport capability for performing RPCs
against multiple remote servers from one datagram socket.  (not
broadcast RPC, but simply sharing one socket amongst multiple datagram
RPC consumers on the client).

This kind of transport would definitely help the mount port limitation
-- the kernel mount client and the kernel rpcbind client could do all
their UDP-based traffic through a single privileged socket.  Would it
be hard to share an rpc_xprt between several rpc_clients for a group
of low-volume RPC services?

The RPC client could also provide a small pool of stream transport
sockets for the same purpose.  They can stay connected to a remote
until they time out, or until another local consumer needs to send to
a unique unconnected remote and there aren't any free sockets in the
pool.

Nfs-utils uses the whole range of privileged ports, being careful to
avoid well-known ports for long-lived services.  The kernel should be
able to do this also for short-lived sockets like making a MNT or
rpcbind request.

We could even force the RPC service registration code to use a low
numbered privileged port to avoid the ports normally used by
long-lived RPC sockets.

> So by default (from min/max_resvport and Chuck's "between 2 and 5"
> estimate of privileged ports per mount) you'd get (1024-665)/(2 to 5)
> mounts, so between 71 and 179 mounts, not taking into account what else
> they might be used for.  So that's a bit closer to the point where 1
> port plus or minus might make a difference, OK.

Doing a mount takes some time.  If it takes as long as a second, for
example, for each mount to complete, that gives enough time for one or
more TCP ports used and abandoned for the first mounts to become
available again for later ones.  If some of the ports are UDP and some
TCP, that means even more ports are available, since the port range is
effectively twice as large, and only the TCP ports remain in
TIME_WAIT.  A MNT request, for instance, goes over UDP by default.

So it's not as simple as this calculation implies -- it depends on
timing, other enabled non-NFS services, and which transports are used
for NFS.  One extra port is noise.

In many cases someone who needs more than a hundred or so mounts can
use unprivileged source ports, as Trond suggested on this list last
week.

>> >     "In most cases, a client with hundreds of mounts will use up
>> >     exactly one extra privileged TCP port to register NLM during the
>> >     first lockd_up() call.  If these are all NFSv4 mounts, it will
>> >     use exactly zero extra ports, since the NFSv4 callback service
>> >     is not even registered.
>> >
>> >     "Considering that _each_ mount operation can take between 2 and
>> >     5 privileged ports, while registering NFSD and NLM both would
>> >     take exactly two ports at boot time, I think that registration
>> >     is wrong place to optimize."
>> >
>> > I'll admit to not following this carefully, but that seemed reasonable
>> > to me.
>>
>> Like it or not, this _is_ a user interface change: if someone has set up
>> their iptables firewall or is using the tcp_wrapper library to limit
>> access to the portmapper (a common practice), then this change is
>> forcing them to change that.

It would have been nice to hear such a specific complaint months ago
when I first suggested doing this on linux-nfs.

>> It is not as if UDP connections are prohibitively difficult to implement
>> either. The entire framework is already there for the TCP case, and so
>> the following patch (as yet untested) should be close...

I don't think CUDP is hard to implement or a bad idea.  It just seemed
like a lot to do for a simple change that can be accomplished with an
existing transport implementation.

>> --------------------------------------------------------------------------
>> commit 161c60bc13899b0def4251cffa492ae6faa00b93
>> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date:   Mon Jul 7 17:43:12 2008 -0400
>>
>>     SUNRPC: Add connected sockets for UDP

I haven't looked closely at this in a while, but datagram socket
disconnection events may be reported to kernel datagram sockets via
->sk_error(), and not via an error code from sendmsg() or connect().

Also, do we need a set of shorter reconnect timeout values especially
for UDP sockets?

Is there any possibility that UDP-based RPC servers may see a difference?

A supplemental change might be to make the kernel's mount and rpcbind
clients use RPC_TASK_ONESHOT or whatever we call it.

>>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 4486c59..2e49f5a 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -580,8 +580,8 @@ static int xs_udp_send_request(struct rpc_task *task)
>>                               req->rq_svec->iov_len);
>>
>>       status = xs_sendpages(transport->sock,
>> -                           xs_addr(xprt),
>> -                           xprt->addrlen, xdr,
>> +                           NULL,
>> +                           0, xdr,
>>                             req->rq_bytes_sent);

This is the only place an address and length are passed to
xs_sendpages(), so you could eliminate these arguments and simplify
xs_sendpages() as a result.

However, if we want both a connected UDP capability and a shared UDP
socket capability, we may need to keep these arguments, and make the
UDP connection logic added below conditional.

>>       dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
>> @@ -1445,13 +1445,13 @@ static inline void xs_reclassify_socket6(struct socket *sock)
>>  }
>>  #endif
>>
>> -static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>> +static int xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>>  {
>>       struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>> +     struct sock *sk = sock->sk;
>> +     int ret;
>>
>>       if (!transport->inet) {
>> -             struct sock *sk = sock->sk;
>> -
>>               write_lock_bh(&sk->sk_callback_lock);
>>
>>               sk->sk_user_data = xprt;
>> @@ -1463,8 +1463,6 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>>               sk->sk_no_check = UDP_CSUM_NORCV;
>>               sk->sk_allocation = GFP_ATOMIC;
>>
>> -             xprt_set_connected(xprt);
>> -
>>               /* Reset to new socket */
>>               transport->sock = sock;
>>               transport->inet = sk;
>> @@ -1472,6 +1470,39 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>>               write_unlock_bh(&sk->sk_callback_lock);
>>       }
>>       xs_udp_do_set_buffer_size(xprt);
>> +     ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, 0);
>> +
>> +     if (ret == 0) {
>> +             spin_lock_bh(&xprt->transport_lock);
>> +             if (sk->sk_state == TCP_ESTABLISHED)
>> +                     xprt_set_connected(xprt);
>> +             spin_unlock_bh(&xprt->transport_lock);
>> +     }
>> +     return ret;
>> +}
>> +
>> +/*
>> + * We need to preserve the port number so the reply cache on the server can
>> + * find our cached RPC replies when we get around to reconnecting.
>> + */
>> +static void xs_sock_reuse_connection(struct rpc_xprt *xprt)
>> +{
>> +     int result;
>> +     struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>> +     struct sockaddr any;
>> +
>> +     dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
>> +
>> +     /*
>> +      * Disconnect the transport socket by doing a connect operation
>> +      * with AF_UNSPEC.  This should return immediately...
>> +      */
>> +     memset(&any, 0, sizeof(any));
>> +     any.sa_family = AF_UNSPEC;
>> +     result = kernel_connect(transport->sock, &any, sizeof(any), 0);
>> +     if (result)
>> +             dprintk("RPC:       AF_UNSPEC connect return code %d\n",
>> +                             result);
>>  }
>>
>>  /**
>> @@ -1491,25 +1522,35 @@ static void xs_udp_connect_worker4(struct work_struct *work)
>>       if (xprt->shutdown || !xprt_bound(xprt))
>>               goto out;
>>
>> -     /* Start by resetting any existing state */
>> -     xs_close(xprt);
>> -
>> -     if ((err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
>> -             dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
>> -             goto out;
>> -     }
>> -     xs_reclassify_socket4(sock);
>> +     if (!sock) {
>> +             if ((err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
>> +                     dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
>> +                     goto out;
>> +             }
>> +             xs_reclassify_socket4(sock);
>>
>> -     if (xs_bind4(transport, sock)) {
>> -             sock_release(sock);
>> -             goto out;
>> -     }
>> +             if (xs_bind4(transport, sock)) {
>> +                     sock_release(sock);
>> +                     goto out;
>> +             }
>> +     } else
>> +             xs_sock_reuse_connection(xprt);
>>
>>       dprintk("RPC:       worker connecting xprt %p to address: %s\n",
>>                       xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
>>
>> -     xs_udp_finish_connecting(xprt, sock);
>> -     status = 0;
>> +     status = xs_udp_finish_connecting(xprt, sock);
>> +     if (status < 0) {
>> +             switch (status) {
>> +                     case -ECONNREFUSED:
>> +                     case -ECONNRESET:
>> +                             /* retry with existing socket, after a delay */
>> +                             break;
>> +                     default:
>> +                             /* get rid of existing socket, and retry */
>> +                             xs_close(xprt);
>> +             }
>> +     }
>>  out:
>>       xprt_wake_pending_tasks(xprt, status);
>>       xprt_clear_connecting(xprt);
>> @@ -1532,54 +1573,40 @@ static void xs_udp_connect_worker6(struct work_struct *work)
>>       if (xprt->shutdown || !xprt_bound(xprt))
>>               goto out;
>>
>> -     /* Start by resetting any existing state */
>> -     xs_close(xprt);
>> -
>> -     if ((err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
>> -             dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
>> -             goto out;
>> -     }
>> -     xs_reclassify_socket6(sock);
>> +     if (!sock) {
>> +             if ((err = sock_create_kern(PF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
>> +                     dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
>> +                     goto out;
>> +             }
>> +             xs_reclassify_socket6(sock);
>>
>> -     if (xs_bind6(transport, sock) < 0) {
>> -             sock_release(sock);
>> -             goto out;
>> -     }
>> +             if (xs_bind6(transport, sock) < 0) {
>> +                     sock_release(sock);
>> +                     goto out;
>> +             }
>> +     } else
>> +             xs_sock_reuse_connection(xprt);
>>
>>       dprintk("RPC:       worker connecting xprt %p to address: %s\n",
>>                       xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
>>
>> -     xs_udp_finish_connecting(xprt, sock);
>> -     status = 0;
>> +     status = xs_udp_finish_connecting(xprt, sock);
>> +     if (status < 0) {
>> +             switch (status) {
>> +                     case -ECONNREFUSED:
>> +                     case -ECONNRESET:
>> +                             /* retry with existing socket, after a delay */
>> +                             break;
>> +                     default:
>> +                             /* get rid of existing socket, and retry */
>> +                             xs_close(xprt);
>> +             }
>> +     }
>>  out:
>>       xprt_wake_pending_tasks(xprt, status);
>>       xprt_clear_connecting(xprt);
>>  }
>>
>> -/*
>> - * We need to preserve the port number so the reply cache on the server can
>> - * find our cached RPC replies when we get around to reconnecting.
>> - */
>> -static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
>> -{
>> -     int result;
>> -     struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>> -     struct sockaddr any;
>> -
>> -     dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
>> -
>> -     /*
>> -      * Disconnect the transport socket by doing a connect operation
>> -      * with AF_UNSPEC.  This should return immediately...
>> -      */
>> -     memset(&any, 0, sizeof(any));
>> -     any.sa_family = AF_UNSPEC;
>> -     result = kernel_connect(transport->sock, &any, sizeof(any), 0);
>> -     if (result)
>> -             dprintk("RPC:       AF_UNSPEC connect return code %d\n",
>> -                             result);
>> -}
>> -
>>  static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
>>  {
>>       struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>> @@ -1650,7 +1677,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
>>               }
>>       } else
>>               /* "close" the socket, preserving the local port */
>> -             xs_tcp_reuse_connection(xprt);
>> +             xs_sock_reuse_connection(xprt);
>>
>>       dprintk("RPC:       worker connecting xprt %p to address: %s\n",
>>                       xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
>> @@ -1710,7 +1737,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
>>               }
>>       } else
>>               /* "close" the socket, preserving the local port */
>> -             xs_tcp_reuse_connection(xprt);
>> +             xs_sock_reuse_connection(xprt);
>>
>>       dprintk("RPC:       worker connecting xprt %p to address: %s\n",
>>                       xprt, xprt->address_strings[RPC_DISPLAY_ALL]);

-- 
Chuck Lever
