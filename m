Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824Ab2AWQv0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 11:51:26 -0500
Date: Mon, 23 Jan 2012 11:51:24 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Clean up the RPCSEC_GSS service ticket requests
Message-ID: <20120123165124.GA32197@fieldses.org>
References: <1325608907-17801-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120103165544.GC6309@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120103165544.GC6309@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 03, 2012 at 11:55:44AM -0500, Bruce Fields wrote:
> On Tue, Jan 03, 2012 at 11:41:47AM -0500, Trond Myklebust wrote:
> > Instead of hacking specific service names into gss_encode_v1_msg, we should
> > just allow the caller to specify the service name explicitly.
> 
> Just curious: do you have some callers in mind he will need different
> service names?
> 
> (But I agree reagardless that this is the more logical layering; fwiw:
> 
> 	Acked-by: J. Bruce Fields <bfields@redhat.com>

Bah, is that what I get for acking without testing?  (Do Bryan's tests not do a
krb5 mount?)

Not sure where the bug is, except on a quick look auth_cred got a princpal
argument, but I can't tell whether it's always initialized.

--b.

general protection fault: 0000 [#1] PREEMPT SMP 
CPU 0 
Modules linked in: rpcsec_gss_krb5 nfs nfsd lockd nfs_acl auth_rpcgss sunrpc [last unloaded: scsi_wait_scan]

Pid: 6645, comm: 192.168.122.11- Not tainted 3.2.0-00001-g68c9715 #966 Bochs Bochs
RIP: 0010:[<ffffffff81516399>]  [<ffffffff81516399>] strnlen+0x9/0x40
RSP: 0018:ffff8800376b77d0  EFLAGS: 00010286
RAX: ffffffff81d027fc RBX: ffff88003758e398 RCX: ffffffffff0a0004
RDX: 5a5a5a5a5a5a5a5a RSI: ffffffffffffffff RDI: 5a5a5a5a5a5a5a5a
RBP: ffff8800376b77d0 R08: 000000000000fffb R09: 0000ffffffffff0a
R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800b758e38f
R13: 5a5a5a5a5a5a5a5a R14: ffffffffffffffff R15: 00000000ffffffff
FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000004073e0 CR3: 0000000001e05000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process 192.168.122.11- (pid: 6645, threadinfo ffff8800376b6000, task ffff88003b576080)
Stack:
 ffff8800376b7820 ffffffff815179ef ffff8800376b7800 ffffffff81097110
 ffff8800376b7810 ffff88003758e398 ffffffffa00524f9 ffffffffa00524f7
 ffff8800376b78a0 ffff8800b758e38f ffff8800376b7890 ffffffff81518b6a
Call Trace:
 [<ffffffff815179ef>] string+0x4f/0xf0
 [<ffffffff81097110>] ? is_module_address+0x30/0x60
 [<ffffffff81518b6a>] vsnprintf+0x1da/0x5b0
 [<ffffffff81088964>] ? static_obj+0x44/0x60
 [<ffffffff81518f80>] sprintf+0x40/0x50
 [<ffffffffa004d938>] gss_setup_upcall+0x1d8/0x2d0 [auth_rpcgss]
 [<ffffffffa004dcc3>] gss_cred_init+0xc3/0x3a0 [auth_rpcgss]
 [<ffffffffa000c3ac>] ? rpcauth_lookup_credcache+0x21c/0x2c0 [sunrpc]
 [<ffffffff81077500>] ? wake_up_bit+0x40/0x40
 [<ffffffff81950afd>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffffa000c327>] rpcauth_lookup_credcache+0x197/0x2c0 [sunrpc]
 [<ffffffffa000c190>] ? rpcauth_refreshcred+0x1d0/0x1d0 [sunrpc]
 [<ffffffff8105b1a2>] ? local_bh_enable_ip+0x82/0x100
 [<ffffffffa004c5ce>] gss_lookup_cred+0xe/0x10 [auth_rpcgss]
 [<ffffffffa000cdbf>] generic_bind_cred+0x1f/0x30 [sunrpc]
 [<ffffffffa000c061>] rpcauth_refreshcred+0xa1/0x1d0 [sunrpc]
 [<ffffffffa00006d3>] call_refresh+0x43/0x70 [sunrpc]
 [<ffffffffa000a8c6>] __rpc_execute+0x66/0x2b0 [sunrpc]
 [<ffffffff810774ef>] ? wake_up_bit+0x2f/0x40
 [<ffffffffa000ab53>] rpc_execute+0x43/0x50 [sunrpc]
 [<ffffffffa0002315>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa0002432>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa00e5a1f>] nfs4_proc_setclientid+0x1af/0x210 [nfs]
 [<ffffffffa00f2e17>] nfs4_init_clientid+0xc7/0x130 [nfs]
 [<ffffffff8194d55b>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffffa00f24dd>] nfs4_run_state_manager+0x2ad/0x600 [nfs]
 [<ffffffffa00f2230>] ? nfs4_do_reclaim+0x590/0x590 [nfs]
 [<ffffffff81076fc6>] kthread+0x96/0xa0
 [<ffffffff81955bf4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81046548>] ? finish_task_switch+0x88/0xf0
 [<ffffffff8194d961>] ? retint_restore_args+0xe/0xe
 [<ffffffff81076f30>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff81955bf0>] ? gs_change+0xb/0xb
Code: 66 90 48 83 c2 01 80 3a 00 75 f7 48 89 d0 48 29 f8 c9 c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 85 f6 48 89 e5 74 2e <80> 3f 00 74 29 48 83 ee 01 48 89 f8 eb 12 66 0f 1f 84 00 00 00 
RIP  [<ffffffff81516399>] strnlen+0x9/0x40
 RSP <ffff8800376b77d0>
---[ end trace bff324891ae17805 ]---


> 
> .)
> 
> --b.
> 
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/client.c                 |    2 +-
> >  fs/nfsd/nfs4callback.c          |    2 +-
> >  include/linux/sunrpc/auth.h     |    3 +-
> >  include/linux/sunrpc/auth_gss.h |    2 +-
> >  net/sunrpc/auth_generic.c       |    6 +++-
> >  net/sunrpc/auth_gss/auth_gss.c  |   40 ++++++++++++++++++++++----------------
> >  6 files changed, 32 insertions(+), 23 deletions(-)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 873bf00..32ea371 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -185,7 +185,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
> >  	clp->cl_minorversion = cl_init->minorversion;
> >  	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
> >  #endif
> > -	cred = rpc_lookup_machine_cred();
> > +	cred = rpc_lookup_machine_cred("*");
> >  	if (!IS_ERR(cred))
> >  		clp->cl_machine_cred = cred;
> >  	nfs_fscache_get_client_cookie(clp);
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 7748d6a..6f3ebb4 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -718,7 +718,7 @@ int set_callback_cred(void)
> >  {
> >  	if (callback_cred)
> >  		return 0;
> > -	callback_cred = rpc_lookup_machine_cred();
> > +	callback_cred = rpc_lookup_machine_cred("nfs");
> >  	if (!callback_cred)
> >  		return -ENOMEM;
> >  	return 0;
> > diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> > index febc4db..7874a8a 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -26,6 +26,7 @@ struct auth_cred {
> >  	uid_t	uid;
> >  	gid_t	gid;
> >  	struct group_info *group_info;
> > +	const char *principal;
> >  	unsigned char machine_cred : 1;
> >  };
> >  
> > @@ -127,7 +128,7 @@ void			rpc_destroy_generic_auth(void);
> >  void 			rpc_destroy_authunix(void);
> >  
> >  struct rpc_cred *	rpc_lookup_cred(void);
> > -struct rpc_cred *	rpc_lookup_machine_cred(void);
> > +struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
> >  int			rpcauth_register(const struct rpc_authops *);
> >  int			rpcauth_unregister(const struct rpc_authops *);
> >  struct rpc_auth *	rpcauth_create(rpc_authflavor_t, struct rpc_clnt *);
> > diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
> > index 8eee9db..f1cfd4c 100644
> > --- a/include/linux/sunrpc/auth_gss.h
> > +++ b/include/linux/sunrpc/auth_gss.h
> > @@ -82,8 +82,8 @@ struct gss_cred {
> >  	enum rpc_gss_svc	gc_service;
> >  	struct gss_cl_ctx __rcu	*gc_ctx;
> >  	struct gss_upcall_msg	*gc_upcall;
> > +	const char		*gc_principal;
> >  	unsigned long		gc_upcall_timestamp;
> > -	unsigned char		gc_machine_cred : 1;
> >  };
> >  
> >  #endif /* __KERNEL__ */
> > diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> > index e010a01..1426ec3 100644
> > --- a/net/sunrpc/auth_generic.c
> > +++ b/net/sunrpc/auth_generic.c
> > @@ -41,15 +41,17 @@ EXPORT_SYMBOL_GPL(rpc_lookup_cred);
> >  /*
> >   * Public call interface for looking up machine creds.
> >   */
> > -struct rpc_cred *rpc_lookup_machine_cred(void)
> > +struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
> >  {
> >  	struct auth_cred acred = {
> >  		.uid = RPC_MACHINE_CRED_USERID,
> >  		.gid = RPC_MACHINE_CRED_GROUPID,
> > +		.principal = service_name,
> >  		.machine_cred = 1,
> >  	};
> >  
> > -	dprintk("RPC:       looking up machine cred\n");
> > +	dprintk("RPC:       looking up machine cred for service %s\n",
> > +			service_name);
> >  	return generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index afb5655..28d72d2 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -392,7 +392,8 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
> >  }
> >  
> >  static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
> > -				struct rpc_clnt *clnt, int machine_cred)
> > +				struct rpc_clnt *clnt,
> > +				const char *service_name)
> >  {
> >  	struct gss_api_mech *mech = gss_msg->auth->mech;
> >  	char *p = gss_msg->databuf;
> > @@ -407,12 +408,8 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
> >  		p += len;
> >  		gss_msg->msg.len += len;
> >  	}
> > -	if (machine_cred) {
> > -		len = sprintf(p, "service=* ");
> > -		p += len;
> > -		gss_msg->msg.len += len;
> > -	} else if (!strcmp(clnt->cl_program->name, "nfs4_cb")) {
> > -		len = sprintf(p, "service=nfs ");
> > +	if (service_name != NULL) {
> > +		len = sprintf(p, "service=%s ", service_name);
> >  		p += len;
> >  		gss_msg->msg.len += len;
> >  	}
> > @@ -429,17 +426,18 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
> >  }
> >  
> >  static void gss_encode_msg(struct gss_upcall_msg *gss_msg,
> > -				struct rpc_clnt *clnt, int machine_cred)
> > +				struct rpc_clnt *clnt,
> > +				const char *service_name)
> >  {
> >  	if (pipe_version == 0)
> >  		gss_encode_v0_msg(gss_msg);
> >  	else /* pipe_version == 1 */
> > -		gss_encode_v1_msg(gss_msg, clnt, machine_cred);
> > +		gss_encode_v1_msg(gss_msg, clnt, service_name);
> >  }
> >  
> > -static inline struct gss_upcall_msg *
> > -gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt,
> > -		int machine_cred)
> > +static struct gss_upcall_msg *
> > +gss_alloc_msg(struct gss_auth *gss_auth, struct rpc_clnt *clnt,
> > +		uid_t uid, const char *service_name)
> >  {
> >  	struct gss_upcall_msg *gss_msg;
> >  	int vers;
> > @@ -459,7 +457,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid, struct rpc_clnt *clnt,
> >  	atomic_set(&gss_msg->count, 1);
> >  	gss_msg->uid = uid;
> >  	gss_msg->auth = gss_auth;
> > -	gss_encode_msg(gss_msg, clnt, machine_cred);
> > +	gss_encode_msg(gss_msg, clnt, service_name);
> >  	return gss_msg;
> >  }
> >  
> > @@ -471,7 +469,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
> >  	struct gss_upcall_msg *gss_new, *gss_msg;
> >  	uid_t uid = cred->cr_uid;
> >  
> > -	gss_new = gss_alloc_msg(gss_auth, uid, clnt, gss_cred->gc_machine_cred);
> > +	gss_new = gss_alloc_msg(gss_auth, clnt, uid, gss_cred->gc_principal);
> >  	if (IS_ERR(gss_new))
> >  		return gss_new;
> >  	gss_msg = gss_add_msg(gss_new);
> > @@ -995,7 +993,9 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
> >  	 */
> >  	cred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_NEW;
> >  	cred->gc_service = gss_auth->service;
> > -	cred->gc_machine_cred = acred->machine_cred;
> > +	cred->gc_principal = NULL;
> > +	if (acred->machine_cred)
> > +		cred->gc_principal = acred->principal;
> >  	kref_get(&gss_auth->kref);
> >  	return &cred->gc_base;
> >  
> > @@ -1030,7 +1030,12 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
> >  	if (!test_bit(RPCAUTH_CRED_UPTODATE, &rc->cr_flags))
> >  		return 0;
> >  out:
> > -	if (acred->machine_cred != gss_cred->gc_machine_cred)
> > +	if (acred->principal != NULL) {
> > +		if (gss_cred->gc_principal == NULL)
> > +			return 0;
> > +		return strcmp(acred->principal, gss_cred->gc_principal) == 0;
> > +	}
> > +	if (gss_cred->gc_principal != NULL)
> >  		return 0;
> >  	return rc->cr_uid == acred->uid;
> >  }
> > @@ -1104,7 +1109,8 @@ static int gss_renew_cred(struct rpc_task *task)
> >  	struct rpc_auth *auth = oldcred->cr_auth;
> >  	struct auth_cred acred = {
> >  		.uid = oldcred->cr_uid,
> > -		.machine_cred = gss_cred->gc_machine_cred,
> > +		.principal = gss_cred->gc_principal,
> > +		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
> >  	};
> >  	struct rpc_cred *new;
> >  
> > -- 
> > 1.7.7.5
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
