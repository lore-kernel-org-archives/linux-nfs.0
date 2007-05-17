From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Thu, 17 May 2007 20:48:51 +1000
Message-ID: <17996.13075.692664.968549@notabene.brown>
References: <20070516192047.GI9626@sgi.com>
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
	id 1HodXW-0004wk-N1
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:48:58 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HodXY-0007lV-Vp
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:49:01 -0700
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
> Move the code at the beginning of svc_process() that sets up
> page buffers for the reply, into a new sko_prepape_reply
> method in svc_sock_ops.
> 

> +static int
> +svc_tcp_prepare_reply(struct svc_rqst *rqstp)
> +{
> +	struct kvec *resv = &rqstp->rq_res.head[0];
> +
> +	svc_tcpip_prepare_reply(rqstp);
> +
> +	/* tcp needs a space for the record length... */
                     ^^

I appreciate that you are copying a comment verbatim, but can we drop
the 'a'? 

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
