From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Thu, 17 May 2007 20:46:20 +1000
Message-ID: <17996.12924.211214.309207@notabene.brown>
References: <20070516191951.GH9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HodV6-0004hS-8g
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:46:28 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HodV7-0007BP-L8
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:46:31 -0700
In-Reply-To: message from Greg Banks on Thursday May 17
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

On Thursday May 17, gnb@sgi.com wrote:
>  
> @@ -886,7 +883,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
>  static const struct svc_sock_ops svc_udp_ops = {
>  	.sko_name = "udp",
>  	.sko_recvfrom = svc_udp_recvfrom,
> -	.sko_sendto = svc_udp_sendto
> +	.sko_sendto = svc_udp_sendto,
> +	.sko_detach = svc_tcpip_detach,
> +	.sko_free = svc_tcpip_free
>  };

Tiny nit:
  Despite widespread usage, I don't see udp as being a part of
  tcp/ip.  So having a function names *tcpip* in the svc_udp_ops looks
  just wrong.
  Maybe svc_ipsock_detach, svc_ipsock_free ??

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
