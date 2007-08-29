From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 05/20] svc: xpt_max_payload
Date: Wed, 29 Aug 2007 13:40:32 -0400
Message-ID: <46D5AF90.4040607@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162332.15224.4469.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070805090305070900050209"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQRXp-0001mv-Bl
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:41:33 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQRXt-00049o-KQ
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:41:37 -0700
In-Reply-To: <20070820162332.15224.4469.stgit@dell3.ogc.int>
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
--------------070805090305070900050209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Store the max payload supported by the transport in the switch
> instead of reaching into the socket since not all transports 
> (RDMA) have a socket.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    6 ++++++
>  net/sunrpc/svc.c               |    5 ++---
>  net/sunrpc/svcsock.c           |    2 ++
>  3 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 3faa95c..4e24e6d 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -35,6 +35,12 @@ struct svc_xprt {
>  	 * Return 1 if sufficient space to write reply to network.
>  	 */
>  	int			(*xpt_has_wspace)(struct svc_sock *);
> +	/*
> +	 * Stores the largest payload (i.e. READ, WRITE or READDIR
> +	 * data length not including NFS headers) supported by the
> +	 * svc_sock.
> +	 */
> +	u32			xpt_max_payload;
>  };

Only worth 2 cents, but perhaps you could make a separate section within 
svc_xprt for these variables, rather than mixing them with the xpt 
methods.  I think separating these is more traditional Linux style.

I notice that the type of the client's rpc_xprt->max_payload is size_t, 
which may be the wrong type -- u32 might be better.

>  /*
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 72a900f..41f9ee0 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1036,10 +1036,9 @@ err_bad:
>   */
>  u32 svc_max_payload(const struct svc_rqst *rqstp)
>  {
> -	int max = RPCSVC_MAXPAYLOAD_TCP;
> +	struct svc_sock *svsk = rqstp->rq_sock;
> +	int max = svsk->sk_xprt->xpt_max_payload;
>  
> -	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
> -		max = RPCSVC_MAXPAYLOAD_UDP;
>  	if (rqstp->rq_server->sv_max_payload < max)
>  		max = rqstp->rq_server->sv_max_payload;
>  	return max;
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b16dad4..0dc94a8 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -897,6 +897,7 @@ static const struct svc_xprt svc_udp_xpr
>  	.xpt_detach = svc_sock_detach,
>  	.xpt_free = svc_sock_free,
>  	.xpt_has_wspace = svc_udp_has_wspace,
> +	.xpt_max_payload = RPCSVC_MAXPAYLOAD_UDP,
>  };
>  
>  static void
> @@ -1368,6 +1369,7 @@ static const struct svc_xprt svc_tcp_xpr
>  	.xpt_free = svc_sock_free,
>  	.xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
>  	.xpt_has_wspace = svc_tcp_has_wspace,
> +	.xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
>  };
>  
>  static void

--------------070805090305070900050209
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070805090305070900050209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------070805090305070900050209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070805090305070900050209--
