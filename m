From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 14/22] Rewrite nlmsvc_invalidate_all
Date: Fri, 1 Sep 2006 11:36:56 +1000
Message-ID: <17655.36536.196157.374527@cse.unsw.edu.au>
References: <20060805130648.GA8087@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GIxxy-0007tc-Sx
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 18:37:06 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GIxxx-0002ZY-F6
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 18:37:07 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 146941FB13
	for <nfs@lists.sourceforge.net>; Fri,  1 Sep 2006 03:37:03 +0200 (CEST)
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Saturday August 5
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

On Saturday August 5, okir@suse.de wrote:
> From: Olaf Kirch <okir@suse.de>
> Subject: Rewrite nlmsvc_invalidate_all
> 
>   nlm_invalidate_all is a funny little function. It seems the purpose
>   is to simulate a server reboot, and make lockd forget all locks held
>   by NFS clients.
> 
>   But this function does more; it also marks the host structs of all
>   clients for destruction (well, destroys them).
> 
>   This patch moves the destruction of the client hosts from
>   nlmsvc_invalidate_all (in svcsubs.c) to its own function in host.c,
>   and gets rid of the kludgy nlm_find_host function.
> 
>   We should consider dropping this step entirely, and just keep the hosts
>   around (when exiting the main loop, we will call nlm_shutdown_hosts
>   anyway).

Yes, it's a funny little function...
Yes, nlm_find_client is a kludgy and should go.
No, it doesn't destroy the host structs.
It sets the h_expiry to 0, which might have been meant to destroy them
on the next garbage-collect run, but often won't.
So as it wasn't doing anything useful before, maybe we should go ahead
with your final suggestion and skip this step entirely...

nlmsvc_invalidate_all is called at two places.
One is when lockd is shutting down.  The very next thing that happens
is nlm_shutdown_hosts is called which removes all hosts.
So doing anything to hosts in nlmsvc_invalidate_all in that case is
pointless.

The other case is when lockd is signalled to ask it to drop all locks.
One could possibly argue there that we should clear sm_monitored
to force re-monitoring of all hosts (maybe statd died and had to be
restarted..) but as we don't do that now, I think that should be a
separate patch with separate justification.

So I'm going to rip out nlm_destroy clients for now.

NeilBrown


> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> 
>  fs/lockd/host.c             |   43 ++++++++++++++++++++++++++++---------------
>  fs/lockd/svcsubs.c          |   11 +++--------
>  include/linux/lockd/lockd.h |    5 ++---
>  3 files changed, 33 insertions(+), 26 deletions(-)
> 
> Index: build/fs/lockd/host.c
> ===================================================================
> --- build.orig/fs/lockd/host.c
> +++ build/fs/lockd/host.c
> @@ -192,30 +192,43 @@ nlm_destroy_host(struct nlm_host *host)
>  	kfree(host);
>  }
>  
> -struct nlm_host *
> -nlm_find_client(void)
> +/*
> + * Destroy all host structs for our clients.
> + */
> +void
> +nlm_destroy_clients(void)
>  {
>  	struct hlist_head *chain;
> -	struct hlist_node *pos;
> +	struct hlist_node *pos, *next;
>  
> -	/* find a nlm_host for a client for which h_killed == 0.
> -	 * and return it
> -	 */
>  	mutex_lock(&nlm_host_mutex);
>  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
>  		struct nlm_host *host;
>  
> -		hlist_for_each_entry(host, pos, chain, h_hash) {
> -			if (host->h_server &&
> -			    host->h_killed == 0) {
> -				nlm_get_host(host);
> -				mutex_unlock(&nlm_host_mutex);
> -				return host;
> -			}
> -		}
> +		hlist_for_each_entry_safe(host, pos, next, chain, h_hash) {
> +			if (!host->h_server)
> +				continue;
> +
> +			/* Remove from hash list. This will also
> +			 * tell nlm_release_host that it should
> +			 * destroy this host when the refcount
> +			 * reaches 0.
> +			 */
> +			hlist_del_init(&host->h_hash);
> +			if (atomic_read(&host->h_count) == 0) {
> +				nlm_destroy_host(host);
> +			} else {
> +				/* This shouldn't happen, but it's not a desaster
> +				 * either. nlm_release_host will just destroy it
> +				 * later. */
> +				printk(KERN_NOTICE "lockd: host %s has refcount %u "
> +						"in nlm_destroy_clients\n",
> +						host->h_name,
> +						atomic_read(&host->h_count));
> +  			}
> +  		}
>  	}
>  	mutex_unlock(&nlm_host_mutex);
> -	return NULL;
>  }
>  
>  				
> Index: build/fs/lockd/svcsubs.c
> ===================================================================
> --- build.orig/fs/lockd/svcsubs.c
> +++ build/fs/lockd/svcsubs.c
> @@ -351,13 +351,11 @@ nlmsvc_free_host_resources(struct nlm_ho
>  }
>  
>  /*
> - * delete all hosts structs for clients
> + * Delete all hosts structs for clients
>   */
>  void
>  nlmsvc_invalidate_all(void)
>  {
> -	struct nlm_host *host;
> -
>  	/* Release all locks held by a NFS clients.
>  	 * Previously, the code would call
>  	 * nlmsvc_free_host_resources for each client in
> @@ -365,9 +363,6 @@ nlmsvc_invalidate_all(void)
>  	 */
>  	nlm_traverse_files(NULL, nlmsvc_is_client);
>  
> -	while ((host = nlm_find_client()) != NULL) {
> -		host->h_expires = 0;
> -		host->h_killed = 1;
> -		nlm_release_host(host);
> -	}
> +	/* Then destroy the host handles */
> +	nlm_destroy_clients();
>  }
> Index: build/include/linux/lockd/lockd.h
> ===================================================================
> --- build.orig/include/linux/lockd/lockd.h
> +++ build/include/linux/lockd/lockd.h
> @@ -45,8 +45,7 @@ struct nlm_host {
>  	unsigned short		h_proto;	/* transport proto */
>  	unsigned short		h_reclaiming : 1,
>  				h_server     : 1, /* server side, not client side */
> -				h_inuse      : 1,
> -				h_killed     : 1;
> +				h_inuse      : 1;
>  	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
>  	struct rw_semaphore	h_rwsem;	/* Reboot recovery lock */
>  	u32			h_state;	/* pseudo-state counter */
> @@ -171,7 +170,7 @@ void		  nlm_rebind_host(struct nlm_host 
>  struct nlm_host * nlm_get_host(struct nlm_host *);
>  void		  nlm_release_host(struct nlm_host *);
>  void		  nlm_shutdown_hosts(void);
> -extern struct nlm_host *nlm_find_client(void);
> +void		  nlm_destroy_clients(void);
>  extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *, int, u32);
>  struct nsm_handle *nsm_find(const struct sockaddr_in *, const char *, int);
>  void		  nsm_release(struct nsm_handle *);
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys -- and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
