From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Lock client list while detaching locks
Date: Fri, 1 Aug 2003 12:21:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16169.52925.519048.996018@gargle.gargle.HOWL>
References: <Pine.LNX.4.33.0307312014470.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iPYO-0007ib-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 19:22:00 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 1 Aug 2003 12:21:53 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Thursday July 31
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday July 31, markhe@veritas.com wrote:
>   Patch against 2.4.21-pre9.
> 
> Mark

Thanks.  I'll forward it to Marcelo.

NeilBrown

> 
> diff -urN linux-2.4.21-pre9/fs/nfsd/export.c nlmdetach/fs/nfsd/export.c
> --- linux-2.4.21-pre9/fs/nfsd/export.c	2003-07-31 20:49:28.000000000 +0100
> +++ nlmdetach/fs/nfsd/export.c	2003-07-31 21:08:56.000000000 +0100
> @@ -903,8 +903,10 @@
>  {
>  	struct svc_client	*clp;
> 
> +	exp_readlock();
>  	for (clp = clients; clp; clp = clp->cl_next)
>  		nfsd_lockd_unexport(clp);
> +	exp_unlock();
>  }
> 
>  /*


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
