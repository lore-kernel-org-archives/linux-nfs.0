From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 09/20] svc: Add SK_LISTENER flag
Date: Wed, 29 Aug 2007 14:41:22 -0400
Message-ID: <46D5BDD2.1040203@oracle.com>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162340.15224.63721.stgit@dell3.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080706020503060405020007"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQSU9-0008FH-HS
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:41:49 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQSUD-00065G-Qs
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:41:54 -0700
In-Reply-To: <20070820162340.15224.63721.stgit@dell3.ogc.int>
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
--------------080706020503060405020007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Tom Tucker wrote:
> Use a new svc_sock flag, SK_LISTENER, that is permanently set on
> listener sockets. Use that to test for listeners in a way that
> is not TCP-specific and does not assume the presence of a socket.

OK, this should go before the previous patch that moves the TCP_LISTEN 
check into svc_recv.

> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
> 
>  include/linux/sunrpc/svcsock.h |    1 +
>  net/sunrpc/svcsock.c           |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 7663578..ea8b62b 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -70,6 +70,7 @@ #define	SK_CHNGBUF	7			/* need to change
>  #define	SK_DEFERRED	8			/* request on sk_deferred */
>  #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
>  #define	SK_DETACHED	10			/* detached from tempsocks list */
> +#define	SK_LISTENER	11			/* listener (e.g. TCP) socket */
>  
>  	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
>  
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 94eb921..dcb5c7a 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1368,6 +1368,7 @@ svc_tcp_init(struct svc_sock *svsk)
>  	if (sk->sk_state == TCP_LISTEN) {
>  		dprintk("setting up TCP socket for listening\n");
>  		sk->sk_data_ready = svc_tcp_listen_data_ready;
> +		set_bit(SK_LISTENER, &svsk->sk_flags);
>  		set_bit(SK_CONN, &svsk->sk_flags);
>  	} else {
>  		dprintk("setting up TCP socket for reading\n");
> @@ -1515,7 +1516,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
>  	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
>  		dprintk("svc_recv: found SK_CLOSE\n");
>  		svc_delete_socket(svsk);
> -	} else if (svsk->sk_sk->sk_state == TCP_LISTEN) {
> +	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
>  		svsk->sk_xprt->xpt_accept(svsk);
>  		svc_sock_received(svsk);
>  	} else {


--------------080706020503060405020007
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


--------------080706020503060405020007
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------080706020503060405020007
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080706020503060405020007--
