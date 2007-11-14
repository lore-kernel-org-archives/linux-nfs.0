From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 05/25] NFS: eliminate
	NIPQUAD(clp->cl_addr.sin_addr)
Date: Wed, 14 Nov 2007 10:45:33 +0900 (JST)
Message-ID: <20071114.104533.127429382.yoshfuji@linux-ipv6.org>
References: <20071113183126.5087.27810.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is7Jx-000239-Qo
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 17:45:38 -0800
Received: from yue.linux-ipv6.org ([203.178.140.15] helo=yue.st-paulia.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is7K2-0005JI-Fj
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 17:45:43 -0800
In-Reply-To: <20071113183126.5087.27810.stgit@manray.1015granger.net>
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

In article <20071113183126.5087.27810.stgit@manray.1015granger.net> (at Tue, 13 Nov 2007 13:31:27 -0500), Chuck Lever <chuck.lever@oracle.com> says:

>  		   clp->rpc_ops->version,
> -		   NIPQUAD(clp->cl_addr.sin_addr),
> -		   ntohs(clp->cl_addr.sin_port),
> +		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
> +		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
>  		   atomic_read(&clp->cl_count),

Is this really safe?

--yoshfuji

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
