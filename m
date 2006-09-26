From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/4 Revised] NLM failover - statd changes
Date: Tue, 26 Sep 2006 10:54:29 +1000
Message-ID: <17688.31301.427937.926300@cse.unsw.edu.au>
References: <4508DFA0.2060806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GS1Db-0001iw-2F
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:54:39 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GS1Db-00044z-5r
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:54:40 -0700
To: wcheng@redhat.com
In-Reply-To: message from Wendy Cheng on Thursday September 14
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday September 14, wcheng@redhat.com wrote:
> This kernel patch should be paired with nfs-utils user mode changes (in 
> patch 4-4 based on nfs-utils-1.0.8-rc4) that is optional. If changes 
> made in patch 4-4 is not presented in nfs-utils, the rpc.statd will 
> ignore whatever this kernel patch does.
> 
> The changes record the ip interface that accepts the lock requests and 
> passes the correct "my_name" (in standard IPV4 dot notation) to user 
> mode statd (instead of system_utsname.nodename). This enables rpc.statd 
> to add the correct taken-over IPv4 address into the 3rd parameter of 
> ha_callout program. Current nfs-utils always resets "my_name" into 
> loopback address (127.0.0.1), regardless the statement made in rpc.statd 
> man page. Check out "man rpc.statd" for details.
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> Signed-off-by: Lon Hohberger  <lhh@redhat.com>
> 
>  fs/lockd/host.c                |    4 ++--
>  fs/lockd/mon.c                 |   21 +++++++++++++++++----
>  fs/lockd/svc4proc.c            |    8 +++++++-
>  fs/lockd/svcproc.c             |    2 +-
>  include/linux/lockd/lockd.h    |    5 +++--
>  include/linux/lockd/sm_inter.h |    1 +
>  include/linux/sunrpc/svc.h     |    5 +++--
>  net/sunrpc/svcsock.c           |    5 +++++
>  8 files changed, 39 insertions(+), 12 deletions(-)
> 
> 
> --- linux-2/include/linux/sunrpc/svc.h	2006-09-11 16:52:34.000000000 -0400
> +++ linux-3/include/linux/sunrpc/svc.h	2006-09-13 14:07:32.000000000 -0400
> @@ -102,6 +102,7 @@ static inline void svc_putu32(struct kve
>  	iov->iov_len += sizeof(u32);
>  }
>  
> +typedef __u32  svc_addr_t;
>  	
>  /*
>   * The context of a single thread, including the request currently being
> @@ -138,8 +139,8 @@ struct svc_rqst {
>  	unsigned short
>  				rq_secure  : 1;	/* secure port */
>  
> -
> -	__u32			rq_daddr;	/* dest addr of request - reply from here */
> +	svc_addr_t		rq_daddr;	/* dest addr of request 
> +						   - reply from here */
>  
>  	void *			rq_argp;	/* decoded arguments */
>  	void *			rq_resp;	/* xdr'd results */
> --- linux-2/include/linux/lockd/lockd.h	2006-09-13 22:48:00.000000000 -0400
> +++ linux-3/include/linux/lockd/lockd.h	2006-09-13 22:51:41.000000000 -0400
> @@ -39,12 +39,13 @@
>  struct nlm_host {
>  	struct nlm_host *	h_next;		/* linked list (hash table) */
>  	struct sockaddr_in	h_addr;		/* peer address */
> +	svc_addr_t		h_server;	/* server ip for NLM failover */

Comment should say 'or 0 for client'.

>  	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
>  	char			h_name[20];	/* remote hostname */
>  	u32			h_version;	/* interface version */
>  	unsigned short		h_proto;	/* transport proto */
>  	unsigned short		h_reclaiming : 1,
> -				h_server     : 1, /* server side, not client side */
> +				h_notused    : 1, 

Just discard this, no need to rename it to 'h_notused'.

>  
> +#if 0
> +	if (argp->reclaim) {
> +		printk("nlm4svc_proc_lock lock reclaim received\n");
> +	}
> +#endif

Can this be removed?


So: mostly looks OK, but will need quite a bit of reworking do to
recent changes in lockd code.  So if you can get me a version that
applies to latest -mm, I'll take it from there.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
