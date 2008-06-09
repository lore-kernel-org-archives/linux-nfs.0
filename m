From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/6] rpc: bring back cl_chatty
Date: Mon, 9 Jun 2008 16:48:18 -0400
Message-ID: <20080609204818.GA32446@fieldses.org>
References: <1213044326-32455-1-git-send-email-bfields@citi.umich.edu> <1213044326-32455-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48614 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753176AbYFIUsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 16:48:19 -0400
In-Reply-To: <1213044326-32455-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Um, sorry, git-send-email wasn't doing what I expected.  Feel free to
ignore this....

--b.

On Mon, Jun 09, 2008 at 04:45:26PM -0400, J. Bruce Fields wrote:
> From: Olga Kornievskaia <aglo@citi.umich.edu>
> 
> The cl_chatty flag alows us to control whether a given rpc client leaves
> 
> 	"server X not responding, timed out"
> 
> messages in the syslog.  Such messages make sense for ordinary nfs
> clients (where an unresponsive server means applications on the
> mountpoint are probably hanging), but not for the callback client (which
> can fail more commonly, with the only result just of disabling some
> optimizations).
> 
> Previously cl_chatty was removed, do to lack of users; reinstate it, and
> use it for the nfsd's callback client.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4callback.c      |    2 +-
>  include/linux/sunrpc/clnt.h |    4 +++-
>  net/sunrpc/clnt.c           |   16 +++++++++++-----
>  3 files changed, 15 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 4d4760e..702fa57 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -381,7 +381,7 @@ static int do_probe_callback(void *data)
>  		.program	= &cb_program,
>  		.version	= nfs_cb_version[1]->number,
>  		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
> -		.flags		= (RPC_CLNT_CREATE_NOPING),
> +		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
>  	};
>  	struct rpc_message msg = {
>  		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 6fff7f8..764fd4c 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -42,7 +42,8 @@ struct rpc_clnt {
>  
>  	unsigned int		cl_softrtry : 1,/* soft timeouts */
>  				cl_discrtry : 1,/* disconnect before retry */
> -				cl_autobind : 1;/* use getport() */
> +				cl_autobind : 1,/* use getport() */
> +				cl_chatty   : 1;/* be verbose */
>  
>  	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
>  	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
> @@ -114,6 +115,7 @@ struct rpc_create_args {
>  #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 3)
>  #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
>  #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
> +#define RPC_CLNT_CREATE_QUIET		(1UL << 6)
>  
>  struct rpc_clnt *rpc_create(struct rpc_create_args *args);
>  struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 8945307..08ec845 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -324,6 +324,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>  		clnt->cl_autobind = 1;
>  	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
>  		clnt->cl_discrtry = 1;
> +	if (!(args->flags & RPC_CLNT_CREATE_QUIET))
> +		clnt->cl_chatty = 1;
>  
>  	return clnt;
>  }
> @@ -1132,7 +1134,8 @@ call_status(struct rpc_task *task)
>  		rpc_exit(task, status);
>  		break;
>  	default:
> -		printk("%s: RPC call returned error %d\n",
> +		if (clnt->cl_chatty)
> +			printk("%s: RPC call returned error %d\n",
>  			       clnt->cl_protname, -status);
>  		rpc_exit(task, status);
>  	}
> @@ -1157,7 +1160,8 @@ call_timeout(struct rpc_task *task)
>  	task->tk_timeouts++;
>  
>  	if (RPC_IS_SOFT(task)) {
> -		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
> +		if (clnt->cl_chatty)
> +			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
>  				clnt->cl_protname, clnt->cl_server);
>  		rpc_exit(task, -EIO);
>  		return;
> @@ -1165,7 +1169,8 @@ call_timeout(struct rpc_task *task)
>  
>  	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
>  		task->tk_flags |= RPC_CALL_MAJORSEEN;
> -		printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
> +		if (clnt->cl_chatty)
> +			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
>  			clnt->cl_protname, clnt->cl_server);
>  	}
>  	rpc_force_rebind(clnt);
> @@ -1196,8 +1201,9 @@ call_decode(struct rpc_task *task)
>  			task->tk_pid, task->tk_status);
>  
>  	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
> -		printk(KERN_NOTICE "%s: server %s OK\n",
> -			clnt->cl_protname, clnt->cl_server);
> +		if (clnt->cl_chatty)
> +			printk(KERN_NOTICE "%s: server %s OK\n",
> +				clnt->cl_protname, clnt->cl_server);
>  		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
>  	}
>  
> -- 
> 1.5.5.rc1
> 
> 
> >From aa856d8b74879d207b35188724917cc426f2b152 Mon Sep 17 00:00:00 2001
> From: Olga Kornievskaia <aglo@citi.umich.edu>
> Date: Sun, 20 Jan 2008 22:25:28 -0500
> Subject: [PATCH 2/6] rpc: timeout patch
> 
> When a client gss upcall times out, we currently give a mesage reminding
> the user to check whether gssd is running.
> 
> Currently gssd only listens on pipes under nfs/.  We expect to modify it
> so it treats all clients the same regardless of protocol (as it probably
> should have before), and new functionality may depend on that.  So
> people may need to upgrade gssd to get such new functionality.
> 
> So it would be helpful if the error message specified which pipe exactly
> the upcall was failing on, and suggested that the problem could be due
> to an outdated gssd (not just a non-existant gssd).
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |   42 +++++++++++++++++++++++++--------------
>  1 files changed, 27 insertions(+), 15 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index cc12d5f..c3ca6f0 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -584,22 +584,34 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
>  {
>  	struct gss_upcall_msg *gss_msg = container_of(msg, struct gss_upcall_msg, msg);
>  	static unsigned long ratelimit;
> +	unsigned long now = jiffies;
> +	struct path path = {
> +		.dentry = gss_msg->auth->dentry,
> +		.mnt = gss_msg->auth->client->cl_vfsmnt,
> +	};
> +	char name[128], *p;
>  
> -	if (msg->errno < 0) {
> -		dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n",
> -				gss_msg);
> -		atomic_inc(&gss_msg->count);
> -		gss_unhash_msg(gss_msg);
> -		if (msg->errno == -ETIMEDOUT) {
> -			unsigned long now = jiffies;
> -			if (time_after(now, ratelimit)) {
> -				printk(KERN_WARNING "RPC: AUTH_GSS upcall timed out.\n"
> -						    "Please check user daemon is running!\n");
> -				ratelimit = now + 15*HZ;
> -			}
> -		}
> -		gss_release_msg(gss_msg);
> -	}
> +	if (msg->errno >= 0)
> +		return;
> +
> +	dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n", gss_msg);
> +	atomic_inc(&gss_msg->count);
> +	gss_unhash_msg(gss_msg);
> +
> +	if (msg->errno != -ETIMEDOUT)
> +		goto out;
> +
> +	if (!time_after(now, ratelimit))
> +		goto out;
> +
> +	p = d_path(&path, name, 128);
> +	printk(KERN_WARNING "RPC: AUTH_GSS upcall to <rpc_pipefs_dir>%s "
> +			    "timed out.\n Please check user daemon is "
> +			    "up-to-date and running!\n", p ? p : "<null>");
> +	ratelimit = now + 15*HZ;
> +
> +out:
> +	gss_release_msg(gss_msg);
>  }
>  
>  /*
> -- 
> 1.5.5.rc1
> 
> 
> >From 7e460fc42e3654aa5c7113ac29e349857617bd11 Mon Sep 17 00:00:00 2001
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Date: Tue, 27 May 2008 16:31:41 -0400
> Subject: [PATCH 3/6] rpc: eliminate unused variable in auth_gss upcall code
> 
> Also, a minor comment grammar fix in the same file.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index c3ca6f0..92a820e 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -272,7 +272,7 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
>  	return NULL;
>  }
>  
> -/* Try to add a upcall to the pipefs queue.
> +/* Try to add an upcall to the pipefs queue.
>   * If an upcall owned by our uid already exists, then we return a reference
>   * to that upcall instead of adding the new upcall.
>   */
> @@ -493,7 +493,6 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  {
>  	const void *p, *end;
>  	void *buf;
> -	struct rpc_clnt *clnt;
>  	struct gss_upcall_msg *gss_msg;
>  	struct inode *inode = filp->f_path.dentry->d_inode;
>  	struct gss_cl_ctx *ctx;
> @@ -507,7 +506,6 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  	if (!buf)
>  		goto out;
>  
> -	clnt = RPC_I(inode)->private;
>  	err = -EFAULT;
>  	if (copy_from_user(buf, src, mlen))
>  		goto err;
> -- 
> 1.5.5.rc1
> 
> 
> >From dedd9b414b8d4e3398579f21b694208e694a7ae8 Mon Sep 17 00:00:00 2001
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Date: Tue, 20 May 2008 10:42:01 -0400
> Subject: [PATCH 4/6] rpc: remove some unused macros
> 
> There used to be a print_hexl() function that used isprint(), now gone.
> I don't know why NFS_NGROUPS and CA_RUN_AS_MACHINE were here.
> 
> I also don't know why another #define that's actually used was marked
> "unused".
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |   13 +------------
>  1 files changed, 1 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 92a820e..ff0c2a4 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -63,22 +63,11 @@ static const struct rpc_credops gss_nullops;
>  # define RPCDBG_FACILITY	RPCDBG_AUTH
>  #endif
>  
> -#define NFS_NGROUPS	16
> -
> -#define GSS_CRED_SLACK		1024		/* XXX: unused */
> +#define GSS_CRED_SLACK		1024
>  /* length of a krb5 verifier (48), plus data added before arguments when
>   * using integrity (two 4-byte integers): */
>  #define GSS_VERF_SLACK		100
>  
> -/* XXX this define must match the gssd define
> -* as it is passed to gssd to signal the use of
> -* machine creds should be part of the shared rpc interface */
> -
> -#define CA_RUN_AS_MACHINE  0x00000200
> -
> -/* dump the buffer in `emacs-hexl' style */
> -#define isprint(c)      ((c > 0x1f) && (c < 0x7f))
> -
>  struct gss_auth {
>  	struct kref kref;
>  	struct rpc_auth rpc_auth;
> -- 
> 1.5.5.rc1
> 
> 
> >From 0a0d4e3e56351897b2a191e515cf9290bef35430 Mon Sep 17 00:00:00 2001
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Date: Tue, 27 May 2008 16:21:01 -0400
> Subject: [PATCH 5/6] rpc: minor cleanup of scheduler callback code
> 
> Try to make the comment here a little more clear and concise.
> 
> Also, this macro definition seems unnecessary.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  include/linux/sunrpc/sched.h |    1 -
>  net/sunrpc/sched.c           |   14 +++++---------
>  2 files changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index d1a5c8c..64981a2 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -135,7 +135,6 @@ struct rpc_task_setup {
>  #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
>  #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
>  #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
> -#define RPC_DO_CALLBACK(t)	((t)->tk_callback != NULL)
>  #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
>  
>  #define RPC_TASK_RUNNING	0
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 6eab9bf..6288af0 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -626,19 +626,15 @@ static void __rpc_execute(struct rpc_task *task)
>  		/*
>  		 * Execute any pending callback.
>  		 */
> -		if (RPC_DO_CALLBACK(task)) {
> -			/* Define a callback save pointer */
> +		if (task->tk_callback) {
>  			void (*save_callback)(struct rpc_task *);
>  
>  			/*
> -			 * If a callback exists, save it, reset it,
> -			 * call it.
> -			 * The save is needed to stop from resetting
> -			 * another callback set within the callback handler
> -			 * - Dave
> +			 * We set tk_callback to NULL before calling it,
> +			 * in case it sets the tk_callback field itself:
>  			 */
> -			save_callback=task->tk_callback;
> -			task->tk_callback=NULL;
> +			save_callback = task->tk_callback;
> +			task->tk_callback = NULL;
>  			save_callback(task);
>  		}
>  
> -- 
> 1.5.5.rc1
> 
> 
> >From 232263856bc583c04b151bd275f2cdf145b384a0 Mon Sep 17 00:00:00 2001
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Date: Fri, 9 May 2008 15:10:56 -0700
> Subject: [PATCH 6/6] nfs: Fix misparsing of nfsv4 fs_locations attribute
> 
> The code incorrectly assumes here that the server name (or ip address)
> is null-terminated.  This can cause referrals to fail in some cases.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/nfs4namespace.c |   34 ++++++++++------------------------
>  1 files changed, 10 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index b112857..2f3eabe 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
>  	return 0;
>  }
>  
> -/*
> - * Check if the string represents a "valid" IPv4 address
> - */
> -static inline int valid_ipaddr4(const char *buf)
> -{
> -	int rc, count, in[4];
> -
> -	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> -	if (rc != 4)
> -		return -EINVAL;
> -	for (count = 0; count < 4; count++) {
> -		if (in[count] > 255)
> -			return -EINVAL;
> -	}
> -	return 0;
> -}
> -
>  /**
>   * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
>   * @mnt_parent - mountpoint of parent directory
> @@ -172,19 +155,20 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>  
>  		s = 0;
>  		while (s < location->nservers) {
> +			const struct nfs4_string *buf = &location->servers[s];
>  			struct sockaddr_in addr = {
>  				.sin_family	= AF_INET,
>  				.sin_port	= htons(NFS_PORT),
>  			};
> +			u8 *ip = (u8 *)addr.sin_addr.s_addr;
>  
> -			if (location->servers[s].len <= 0 ||
> -			    valid_ipaddr4(location->servers[s].data) < 0) {
> -				s++;
> -				continue;
> -			}
> +			if (buf->len <= 0 || buf->len >= PAGE_SIZE)
> +				goto next;
> +			if (!in4_pton(buf->data, buf->len, ip, '\0', NULL))
> +				goto next;
>  
> -			mountdata.hostname = location->servers[s].data;
> -			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
> +			mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
> +			mountdata.hostname[buf->len] = 0;
>  			mountdata.addr = (struct sockaddr *)&addr;
>  			mountdata.addrlen = sizeof(addr);
>  
> @@ -193,9 +177,11 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
>  					mountdata.mnt_path);
>  
>  			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
> +			kfree(mountdata.hostname);
>  			if (!IS_ERR(mnt)) {
>  				break;
>  			}
> +next:
>  			s++;
>  		}
>  		loc++;
> -- 
> 1.5.5.rc1
> 
