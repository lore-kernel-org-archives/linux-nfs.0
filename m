From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 18/20] SUNRPC: Add IPv6 address
	support	to	net/sunrpc/xprtsock.c
Date: Mon, 13 Aug 2007 13:53:34 -0400
Message-ID: <46C09A9E.8050602@oracle.com>
References: <20070806155753.31233.82962.stgit@manray.1015granger.net>	<1186844473.17941.23.camel@heimdal.trondhjem.org>
	<46C06350.6080709@oracle.com> <46C09979.4040402@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040102060202090508010208"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKe8Z-0001We-Oj
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:55:38 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKe8c-0000ap-NA
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:55:36 -0700
In-Reply-To: <46C09979.4040402@redhat.com>
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

This is a multi-part message in MIME format.
--------------040102060202090508010208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> Trond Myklebust wrote:
>>> On Mon, 2007-08-06 at 11:57 -0400, Chuck Lever wrote:
>>>> Finalize support for setting up RPC client transports to remote RPC
>>>> services addressed via IPv6.
>>>>
>>>> Based on work done by Gilles Quillard at Bull Open Source.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
>>>> ---
>>>>
>>>>  net/sunrpc/xprtsock.c |   57 
>>>> ++++++++++++++++++++++++++++++++++++++++---------
>>>>  1 files changed, 47 insertions(+), 10 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>>> index 391b88d..fb55c1c 100644
>>>> --- a/net/sunrpc/xprtsock.c
>>>> +++ b/net/sunrpc/xprtsock.c
>>>> @@ -13,6 +13,9 @@
>>>>   *  (C) 1999 Trond Myklebust <trond.myklebust@fys.uio.no>
>>>>   *
>>>>   * IP socket transport implementation, (C) 2005 Chuck Lever 
>>>> <cel@netapp.com>
>>>> + *
>>>> + * IPv6 support contributed by Gilles Quillard, Bull Open Source, 
>>>> 2005.
>>>> + *   <gilles.quillard@bull.net>
>>>>   */
>>>>  
>>>>  #include <linux/types.h>
>>>> @@ -1790,6 +1793,7 @@ static struct rpc_xprt *xs_setup_xprt(struct 
>>>> rpc_xprtsock_create *args, unsigned
>>>>   */
>>>>  struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
>>>>  {
>>>> +    struct sockaddr *addr = args->dstaddr;
>>>>      struct rpc_xprt *xprt;
>>>>      struct sock_xprt *transport;
>>>>  
>>>> @@ -1798,15 +1802,11 @@ struct rpc_xprt *xs_setup_udp(struct 
>>>> rpc_xprtsock_create *args)
>>>>          return xprt;
>>>>      transport = container_of(xprt, struct sock_xprt, xprt);
>>>>  
>>>> -    if (ntohs(((struct sockaddr_in *)args->dstaddr)->sin_port) != 0)
>>>> -        xprt_set_bound(xprt);
>>>> -
>>>>      xprt->prot = IPPROTO_UDP;
>>>>      xprt->tsh_size = 0;
>>>>      /* XXX: header size can vary due to auth type, IPv6, etc. */
>>>>      xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
>>>>  
>>>> -    INIT_DELAYED_WORK(&transport->connect_worker, 
>>>> xs_udp_connect_worker4);
>>>>      xprt->bind_timeout = XS_BIND_TO;
>>>>      xprt->connect_timeout = XS_UDP_CONN_TO;
>>>>      xprt->reestablish_timeout = XS_UDP_REEST_TO;
>>>> @@ -1819,7 +1819,28 @@ struct rpc_xprt *xs_setup_udp(struct 
>>>> rpc_xprtsock_create *args)
>>>>      else
>>>>          xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
>>>>  
>>>> -    xs_format_ipv4_peer_addresses(xprt);
>>>> +    switch (addr->sa_family) {
>>>> +    case AF_INET:
>>>> +        if (ntohs(((struct sockaddr_in *)addr)->sin_port) != 0)
>>>
>>> Hmm.... I'm converting these to compare sin_port to htons(0). There is
>>> no need to byte-swap the variable every time we run this code if we can
>>> just have the compiler byte-swap the constant.
>>
>> Not a hot path... but yes, that is true.  Up to you if you want to 
>> change this as described, but my feeling is that would be a little 
>> harder to read.  Your call, of course. 
> 
> Just out of curiosity, do we really need to byte swap the
> value, 0, anyway?

I think Trond noticed that and may have fixed it in his version.

--------------040102060202090508010208
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------040102060202090508010208
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040102060202090508010208
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040102060202090508010208--
