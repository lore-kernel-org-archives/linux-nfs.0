From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 2/4] svc: svc_addsock needs to set the svc_xprt address
Date: Mon, 22 Oct 2007 17:15:47 +1000
Message-ID: <20071022071547.GB27129@sgi.com>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
	<20071019214525.31422.35242.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjrT6-0006XK-1Y
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 00:12:56 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19RRZ1cDcL9GjZK3hMLj6wGYub6M04I5Ew=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IjrTA-00071f-7X
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 00:13:01 -0700
In-Reply-To: <20071019214525.31422.35242.stgit@dell3.ogc.int>
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

On Fri, Oct 19, 2007 at 04:45:26PM -0500, Tom Tucker wrote:
> 
> The svc_addsock function needs to set the local address in the 
> svc_xprt structure.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  net/sunrpc/svcsock.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index cc752b7..e1a27ee 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1249,6 +1249,11 @@ int svc_addsock(struct svc_serv *serv,
>  	else {
>  		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
>  		if (svsk) {
> +			int salen;
> +			(void)kernel_getsockname(svsk->sk_sock,
> +						 (struct sockaddr *)
> +						 &svsk->sk_xprt.xpt_local,
> +						 &salen);
>  			svc_xprt_received(&svsk->sk_xprt);
>  			err = 0;
>  		}

I presume you did this to make UDP work again after you broke it in
patch "Move the sockaddr information to svc_xprt" ?  I think this is
subtly wrong.

If you read svc_udp_recvfrom() more closely you'll see why.  That code
uses struct in_pktinfo (in6_pktinfo on ipv6) to fill in rqstp->rq_daddr
with the destination address that each incoming RPC has on the wire.

The other patch plus this one instead fill in rq_daddr with the UDP
socket's idea of it's own address, which does not vary for each call
and will usually be 0.0.0.0:2049.  So later svc_sendto() will attempt
to send the reply with a source address of 0.0.0.0:2049.

That will result in the networking layer choosing a source address
based on the interface through which the datagram is routed.
Most of the time that works fine but there are setups where this will
completely break NFS.  For example, an HA configuration (where all NFS
traffic is sent to IP aliases, not the interface's primary address)
combined with careful firewall rules.

Perhaps I wasn't clear in my response to patch "Move the sockaddr
information to svc_xprt".  The assumption in that patch that
svsk->sk_local is meaningful for the UDP socket, and can be used to
generate rqstp->rq_daddr, is incorrect.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
