From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH] svc: Fix the UDP address logic
Date: Tue, 23 Oct 2007 11:13:36 -0500
Message-ID: <471E1DB0.2000407@opengridcomputing.com>
References: <20071022210148.9997.94538.stgit@dell3.ogc.int>
	<471E0FA7.5010105@oracle.com>
	<471E1564.8040800@opengridcomputing.com>
	<471E1812.6010906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkMNz-0002Po-Sj
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 09:13:44 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IkMO5-0004HI-1d
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 09:13:49 -0700
In-Reply-To: <471E1812.6010906@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Chuck Lever wrote:
> Tom Tucker wrote:
>> Chuck Lever wrote:
>>> Tom Tucker wrote:
>>>> When the address information was moved to the svc_xprt structure, a 
>>>> bug
>>>> was introduced to UDP that caused an incorrect address to be used
>>>> when responding to RPC on the UDP transport. This was the result of
>>>> failing to completely implement the generic address logic for the 
>>>> UDP transport.
>>>>
>>>> Thanks to Greg for pointing this out...
>>>>
>>>> Since I confused myself, it's probably a good idea to describe how 
>>>> this is supposed to work. The transport is responsible for setting 
>>>> the xpt_local and xpt_remote addresses in the svc_xprt structure as
>>>> part of xpo_recvfrom processing. This cannot be done in a generic 
>>>> way and in fact varies between TCP, UDP and RDMA. A set of xpo_ 
>>>> functions
>>>> (e.g. getlocalname, getremotename) could have been added but this 
>>>> would
>>>> have resulted in additional caching and copying of the addresses 
>>>> around.
>>>> The generic svc_recv code copies the addresses from the svc_xprt 
>>>> structure into the rqstp structure as part of svc_recv processing. 
>>>> The xpt_local address should also be set on listening endpoints, for
>>>> tcp/rdma this is done as part of endpoint creation and for new 
>>>> connections in xpo_accept processing.
>>>> This patch was tested with Connectathon over V3 on UDP.
>>>>
>>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>> ---
>>>>
>>>>  net/sunrpc/svcsock.c |   16 ++++++++++------
>>>>  1 files changed, 10 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>> index e1a27ee..0f8a3d5 100644
>>>> --- a/net/sunrpc/svcsock.c
>>>> +++ b/net/sunrpc/svcsock.c
>>>> @@ -473,17 +473,21 @@ svc_write_space(struct sock *sk)
>>>>  static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
>>>>                          struct cmsghdr *cmh)
>>>>  {
>>>> -    struct svc_sock *svsk =
>>>> -        container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
>>>> +    struct svc_xprt *xprt = rqstp->rq_xprt;
>>>> +    struct svc_sock *svsk = container_of(xprt, struct svc_sock, 
>>>> sk_xprt);
>>>>      switch (svsk->sk_sk->sk_family) {
>>>>      case AF_INET: {
>>>>          struct in_pktinfo *pki = CMSG_DATA(cmh);
>>>> -        rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
>>>> +        struct sockaddr_in *sin =
>>>> +            (struct sockaddr_in *)&xprt->xpt_local;
>>>> +        sin->sin_addr.s_addr = pki->ipi_spec_dst.s_addr;
>>>>          break;
>>>>          }
>>>>      case AF_INET6: {
>>>>          struct in6_pktinfo *pki = CMSG_DATA(cmh);
>>>> -        ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
>>>> +        struct sockaddr_in6 *sin6 =
>>>> +            (struct sockaddr_in6 *)&xprt->xpt_local;
>>>> +        ipv6_addr_copy(&sin6->sin6_addr, &pki->ipi6_addr);
>>>>          break;
>>>>          }
>>>>      }
>>>> @@ -506,7 +510,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>>>>      struct cmsghdr *cmh = &buffer.hdr;
>>>>      int        err, len;
>>>>      struct msghdr msg = {
>>>> -        .msg_name = svc_addr(rqstp),
>>>> +        .msg_name = &svsk->sk_xprt.xpt_remote,
>>>>          .msg_control = cmh,
>>>>          .msg_controllen = sizeof(buffer),
>>>>          .msg_flags = MSG_DONTWAIT,
>>>> @@ -541,7 +545,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>>>>          svc_xprt_received(&svsk->sk_xprt);
>>>>          return -EAGAIN;
>>>>      }
>>>> -    rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
>>>> +    svsk->sk_xprt.xpt_remotelen = sizeof(svsk->sk_xprt.xpt_remote);
>>>
>>> This worries me a bit.  Why isn't rq_addrlen involved here?
>> rq_addrlen gets set in the generic code (see svc_recv). The source of 
>> the address is the transport, not the rqstp structure. The rqstp 
>> structure caches it for use when responding to the request in 
>> svc_process. Ironically, I think the HA case that Greg referred to is 
>> the only reason we can't get rid of rq_addr/rq_daddr altogether and 
>> access the address data directly from svc_xprt. Since this address 
>> may change for UDP, we have to store it in the rqstp structure and 
>> use it to reply because another request could arrive in the interim 
>> and change the address data in svc_xprt.
>>>   the xpt_remote field should be a sockaddr_storage, 
>> ...it is.
>>> and the remote_len field should be the actual length of the address, 
>>> not the size of the storage space.
>> Perhaps it should be, but a) kernel_recvmsg doesn't give us a length, 
>> b) to determine it would require a switch, the degenerate case for 
>> which is sizeof(storage),
>
> I don't agree: there is no degenerate case, and sizeof(storage) should 
> never ever be used.
>
>> and c) in it's current usage, big-enough is good-enough. A weaker 
>> point is "that's the way it's always been" ;-)
>
> Please change it to use an appropriate address length.  Using 
> sizeof(struct sockaddr_storage) is broken, or at the very least 
> inefficient (this struct is huge).  
Yes, for TCP/UDP 128B is getting copied when it really only needs to be 
16 or 28.

> The use of sizeof() here is inconsistent with the design of the IPv6 
> changes I made last year.
Fair enough, but in practical terms that means if ss_family is not 
AF_INET or AF_INET6, we'll return an error or is there something I'm 
missing?


Tom
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
