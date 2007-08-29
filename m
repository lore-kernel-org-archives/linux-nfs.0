From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 02/20] svc: xpt_detach and xpt_free
Date: Wed, 29 Aug 2007 13:08:19 -0400
Message-ID: <20070829170819.GB23541@fieldses.org>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162325.15224.71015.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQR1d-0006mB-R6
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:08:17 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQR1g-0005e0-VR
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 10:08:22 -0700
In-Reply-To: <20070820162325.15224.71015.stgit@dell3.ogc.int>
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

On Mon, Aug 20, 2007 at 11:23:25AM -0500, Tom Tucker wrote:
> @@ -15,6 +15,18 @@ struct svc_xprt {
>  	const char		*xpt_name;
>  	int			(*xpt_recvfrom)(struct svc_rqst *rqstp);
>  	int			(*xpt_sendto)(struct svc_rqst *rqstp);
> +	/*
> +	 * Detach the svc_sock from it's socket, so that the

s/it's/its/

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
