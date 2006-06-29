From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC PATCH 1/3] NLM lock failover - lock release
Date: Thu, 29 Jun 2006 19:06:37 -0400
Message-ID: <1151622397.6405.5.camel@lade.trondhjem.org>
References: <44A417E7.5090500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw5b8-0004lJ-6c
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 16:06:58 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fw5b7-00079j-N1
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 16:06:58 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <44A417E7.5090500@redhat.com>
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

On Thu, 2006-06-29 at 14:11 -0400, Wendy Cheng wrote:
> The patch piggy-backs the logic into "rq_daddr" field of struct svc_rqst 
> where NFS server ip address is stored. Upon writing IPv4 address in 
> standard dot notation into /proc/fs/nfsd/nlm_unlock, the logic will 
> examine NLM's global nlm_files list and subsequently unlock the 
> associated file if server ip address matches.
> 
> Due to the size of rq_daddr (u32), we would not be able to support IPV6 
> for this round of changes. Another to-do item is to enable client:server 
> ip pairs to allow NFS V4 failover.
> 
> 
> 
> 
> plain text document attachment (gfs_nlm_unlock.patch)
>  fs/lockd/svcsubs.c          |   58 ++++++++++++++++++++++++++++++++++++++++----
>  fs/nfsd/nfsctl.c            |   54 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/lockd/bind.h  |    5 +++
>  include/linux/lockd/lockd.h |    3 ++
>  net/sunrpc/svcsock.c        |    5 +++
>  5 files changed, 120 insertions(+), 5 deletions(-)
> 
> --- linux-2.6.17/include/linux/lockd/lockd.h	2006-06-17 21:49:35.000000000 -0400
> +++ linux-2.6.17-1/include/linux/lockd/lockd.h	2006-06-27 10:58:47.000000000 -0400
> @@ -105,6 +105,7 @@ struct nlm_file {
>  	unsigned int		f_count;	/* reference count */
>  	struct semaphore	f_sema;		/* avoid concurrent access */
>  	int		       	f_hash;		/* hash of f_handle */
> +	__u32			f_iaddr;	/* server ip for failover */
>  };
>  
>  /*
> @@ -133,6 +134,7 @@ struct nlm_block {
>  #define NLM_ACT_CHECK		0		/* check for locks */
>  #define NLM_ACT_MARK		1		/* mark & sweep */
>  #define NLM_ACT_UNLOCK		2		/* release all locks */
> +#define NLM_ACT_FO_UNLOCK	3		/* failover release locks */
>  
>  /*
>   * Global variables
> @@ -196,6 +198,7 @@ void		  nlm_release_file(struct nlm_file
>  void		  nlmsvc_mark_resources(void);
>  void		  nlmsvc_free_host_resources(struct nlm_host *);
>  void		  nlmsvc_invalidate_all(void);
> +int 		  nlmsvc_fo_unlock(struct in_addr *);
>  
>  static __inline__ struct inode *
>  nlmsvc_file_inode(struct nlm_file *file)
> --- linux-2.6.17/net/sunrpc/svcsock.c	2006-06-17 21:49:35.000000000 -0400
> +++ linux-2.6.17-1/net/sunrpc/svcsock.c	2006-06-27 10:58:47.000000000 -0400
> @@ -454,6 +454,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
>  	struct msghdr	msg;
>  	struct socket	*sock;
>  	int		len, alen;
> +	struct sockaddr_in   daddr;
>  
>  	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
>  	sock = rqstp->rq_sock->sk_sock;
> @@ -474,6 +475,10 @@ svc_recvfrom(struct svc_rqst *rqstp, str
>  	alen = sizeof(rqstp->rq_addr);
>  	sock->ops->getname(sock, (struct sockaddr *)&rqstp->rq_addr, &alen, 1);
>  
> +	/* add server ip for nlm lock failover */
> +	sock->ops->getname(sock, (struct sockaddr *)&daddr, &alen, 0);
> +	rqstp->rq_daddr = daddr.sin_addr.s_addr;
> +

Hmm.... Why would you want to do this on every receive when you could
just store the ip address in the struct svc_sock once and for all?

That said, how do you envisage this working in the cases where the
socket is bound to INADDR_ANY?

Cheers,
  Trond



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
