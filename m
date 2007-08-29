From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 13/20] svc: Add svc_[un]register_transport
Date: Wed, 29 Aug 2007 15:12:00 -0400
Message-ID: <46D5C500.9050600@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162349.15224.26984.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060902040009050207000405"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQSxj-0003CP-6Q
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:12:23 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQSxm-0003R9-B9
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 12:12:27 -0700
In-Reply-To: <20070820162349.15224.26984.stgit@dell3.ogc.int>
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
--------------060902040009050207000405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Add an exported function for transport modules to [un]register themselves
> with the sunrpc server side transport switch.

In the client side transport switch, I created separate structures for 
the ops vector (that seems like standard practice for Linux), for each 
transport instantiation (ie each socket), and for each transport class 
(ie udp socket type, tcp socket type).  You may be mixing those things 
together here into a single struct.

Or I could be missing something?

> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    6 +++++
>  net/sunrpc/svcsock.c           |   50 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 56 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 7def951..cc911ab 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -13,6 +13,7 @@ #include <linux/sunrpc/svc.h>
>  
>  struct svc_xprt {
>  	const char		*xpt_name;
> +	struct module		*xpt_owner;
>  	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
>  	int			(*xpt_sendto)(struct svc_rqst *rqstp);
>  	/*
> @@ -45,7 +46,10 @@ struct svc_xprt {
>  	 * Accept a pending connection, for connection-oriented transports
>  	 */
>  	int			(*xpt_accept)(struct svc_sock *svsk);
> +	/* Transport list link */
> +	struct list_head	xpt_list;
>  };
> +extern struct list_head svc_transport_list;
>  
>  /*
>   * RPC server socket.
> @@ -102,6 +106,8 @@ #define	SK_LISTENER	11			/* listener (e.
>  /*
>   * Function prototypes.
>   */
> +int 		svc_register_transport(struct svc_xprt *xprt);
> +int 		svc_unregister_transport(struct svc_xprt *xprt);
>  int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
>  void		svc_force_close_socket(struct svc_sock *);
>  int		svc_recv(struct svc_rqst *, long);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 6acf22f..6183951 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -91,6 +91,54 @@ static struct svc_deferred_req *svc_defe
>  static int svc_deferred_recv(struct svc_rqst *rqstp);
>  static struct cache_deferred_req *svc_defer(struct cache_req *req);
>  
> +/* List of registered transports */
> +static spinlock_t svc_transport_lock = SPIN_LOCK_UNLOCKED;
> +LIST_HEAD(svc_transport_list);
> +
> +int svc_register_transport(struct svc_xprt *xprt)
> +{
> +	struct svc_xprt *ops;
> +	int res;
> +
> +	dprintk("svc: Adding svc transport '%s'\n",
> +		xprt->xpt_name);
> +
> +	res = -EEXIST;
> +	INIT_LIST_HEAD(&xprt->xpt_list);
> +	spin_lock(&svc_transport_lock);
> +	list_for_each_entry(ops, &svc_transport_list, xpt_list) {
> +		if (xprt == ops)
> +			goto out;
> +	}
> +	list_add_tail(&xprt->xpt_list, &svc_transport_list);
> +	res = 0;
> +out:
> +	spin_unlock(&svc_transport_lock);
> +	return res;
> +}
> +EXPORT_SYMBOL_GPL(svc_register_transport);
> +
> +int svc_unregister_transport(struct svc_xprt *xprt)
> +{
> +	struct svc_xprt *ops;
> +	int res = 0;
> +
> +	dprintk("svc: Removing svc transport '%s'\n", xprt->xpt_name);
> +
> +	spin_lock(&svc_transport_lock);
> +	list_for_each_entry(ops, &svc_transport_list, xpt_list) {
> +		if (xprt == ops) {
> +			list_del_init(&ops->xpt_list);
> +			goto out;
> +		}
> +	}
> +	res = -ENOENT;
> + out:
> +	spin_unlock(&svc_transport_lock);
> +	return res;
> +}
> +EXPORT_SYMBOL_GPL(svc_unregister_transport);
> +
>  /* apparently the "standard" is that clients close
>   * idle connections after 5 minutes, servers after
>   * 6 minutes
> @@ -887,6 +935,7 @@ svc_udp_has_wspace(struct svc_sock *svsk
>  
>  static const struct svc_xprt svc_udp_xprt = {
>  	.xpt_name = "udp",
> +	.xpt_owner = THIS_MODULE,
>  	.xpt_recvfrom = svc_udp_recvfrom,
>  	.xpt_sendto = svc_udp_sendto,
>  	.xpt_detach = svc_sock_detach,
> @@ -1346,6 +1395,7 @@ svc_tcp_has_wspace(struct svc_sock *svsk
>  
>  static const struct svc_xprt svc_tcp_xprt = {
>  	.xpt_name = "tcp",
> +	.xpt_owner = THIS_MODULE,
>  	.xpt_recvfrom = svc_tcp_recvfrom,
>  	.xpt_sendto = svc_tcp_sendto,
>  	.xpt_detach = svc_sock_detach,


--------------060902040009050207000405
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


--------------060902040009050207000405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060902040009050207000405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060902040009050207000405--
