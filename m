From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Thu, 14 Jul 2005 12:00:11 -0400
Message-ID: <42D68C0B.9000106@RedHat.com>
References: <20050711092556.GD27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt68X-0006Ls-5V
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 09:00:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt68S-0002md-KX
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 09:00:30 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711092556.GD27163@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Olaf Kirch wrote:
>
>  #endif /* _LINUX_SUNRPC_XPRT_H */
> Index: linux-2.6.10/net/sunrpc/sysctl.c
> ===================================================================
> --- linux-2.6.10.orig/net/sunrpc/sysctl.c	2005-02-23 17:17:55.000000000 +0100
> +++ linux-2.6.10/net/sunrpc/sysctl.c	2005-02-23 17:19:35.000000000 +0100
> @@ -29,6 +29,10 @@ unsigned int	nfs_debug;
>  unsigned int	nfsd_debug;
>  unsigned int	nlm_debug;
>  
> +unsigned int	xprt_min_resvport = 650;
> +unsigned int	xprt_max_resvport = 1023;
> +
> +
>  #ifdef RPC_DEBUG
>  
>  static struct ctl_table_header *sunrpc_table_header;
> @@ -121,6 +125,8 @@ done:
>  
>  static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
>  static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
> +static unsigned int xprt_min_resvport_limit = 1;
> +static unsigned int xprt_max_resvport_limit = 65535;
Question, why is 65535 one being used here instead of something
like 1023 (or PROT_SOCK-1)? Since since inet_bind() will only
succeed with a source ports that are less than PROT_SOCK, so it
may not make sense to allow the user to set the max reserver port
to a value greater than PROT_SOCK-1, true?

steved.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
