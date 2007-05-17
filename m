From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 5/14] knfsd: max_payload per transport
Date: Thu, 17 May 2007 20:34:10 +1000
Message-ID: <17996.12194.801580.925774@notabene.brown>
References: <20070516192306.GK9626@sgi.com>
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
	id 1HodJJ-0003FR-4r
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:34:17 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HodJL-0003c1-HK
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:34:20 -0700
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
> Make svc_max_payload() delegate to a new method in svc_sock_ops
> instead of reaching into the socket (beause later the NFS/RDMA
> transport will not even have a socket).
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
..
>  
> +static u32 svc_tcp_max_payload(struct svc_sock *svsk)
> +{
> +	return RPCSVC_MAXPAYLOAD_TCP;
> +}
> +

Seeing these are implementation (or protocol) defined constants, do we
really need a function call?  How about a
	int max_payload;
in struct svc_sock_ops??  Or is it tacky to put an integer in a *_ops
structure? 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
