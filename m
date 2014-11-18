Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35501 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbaKRNyg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2014 08:54:36 -0500
Received: by mail-qg0-f50.google.com with SMTP id e89so5724699qgf.23
        for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 05:54:32 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 18 Nov 2014 08:54:29 -0500
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] sunrpc: eliminate RPC_DEBUG
Message-ID: <20141118085429.3024580e@tlielax.poochiereds.net>
In-Reply-To: <546B4C6A.8040003@Netapp.com>
References: <1416261485-24686-1-git-send-email-jlayton@primarydata.com>
	<1416261485-24686-3-git-send-email-jlayton@primarydata.com>
	<546B4C6A.8040003@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 18 Nov 2014 08:40:58 -0500
Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hi Jeff,
> 
> I'm getting a git error when I try to apply this patch:
> 
> Applying: sunrpc: eliminate RPC_DEBUG
> fatal: sha1 information is lacking or useless (include/linux/sunrpc/debug.h).
> Repository lacks necessary blobs to fall back on 3-way merge.
> Cannot fall back to three-way merge.
> 
> What am I missing?
> 
> Anna
> 

Oh, hmmm...

This patchset is based on top of the patches that adds the new
tracepoints and the debugfs file for dumping the client's rpc_task queue
that I sent on 10/28.

Are you missing those?


> 
> On 11/17/2014 04:58 PM, Jeff Layton wrote:
> > It's always set to whatever CONFIG_SUNRPC_DEBUG is, so just use that.
> >
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  include/linux/sunrpc/auth.h             | 2 +-
> >  include/linux/sunrpc/debug.h            | 9 +++------
> >  include/linux/sunrpc/sched.h            | 8 ++++----
> >  include/uapi/linux/nfsd/debug.h         | 2 +-
> >  net/sunrpc/auth.c                       | 4 ++--
> >  net/sunrpc/auth_generic.c               | 2 +-
> >  net/sunrpc/auth_gss/auth_gss.c          | 2 +-
> >  net/sunrpc/auth_gss/gss_generic_token.c | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_crypto.c   | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_keys.c     | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_mech.c     | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_seal.c     | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_seqnum.c   | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_unseal.c   | 2 +-
> >  net/sunrpc/auth_gss/gss_krb5_wrap.c     | 2 +-
> >  net/sunrpc/auth_gss/gss_mech_switch.c   | 2 +-
> >  net/sunrpc/auth_gss/gss_rpc_xdr.h       | 2 +-
> >  net/sunrpc/auth_gss/svcauth_gss.c       | 2 +-
> >  net/sunrpc/auth_null.c                  | 4 ++--
> >  net/sunrpc/auth_unix.c                  | 2 +-
> >  net/sunrpc/backchannel_rqst.c           | 2 +-
> >  net/sunrpc/clnt.c                       | 6 +++---
> >  net/sunrpc/rpcb_clnt.c                  | 2 +-
> >  net/sunrpc/sched.c                      | 4 ++--
> >  net/sunrpc/sunrpc_syms.c                | 4 ++--
> >  net/sunrpc/svc.c                        | 2 +-
> >  net/sunrpc/sysctl.c                     | 2 +-
> >  net/sunrpc/xprt.c                       | 2 +-
> >  net/sunrpc/xprtrdma/rpc_rdma.c          | 4 ++--
> >  net/sunrpc/xprtrdma/transport.c         | 8 ++++----
> >  net/sunrpc/xprtrdma/verbs.c             | 8 ++++----
> >  net/sunrpc/xprtsock.c                   | 8 ++++----
> >  32 files changed, 53 insertions(+), 56 deletions(-)
> >
> > diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> > index 8e030075fe79..a7cbb570cc5c 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -53,7 +53,7 @@ struct rpc_cred {
> >  	struct rcu_head		cr_rcu;
> >  	struct rpc_auth *	cr_auth;
> >  	const struct rpc_credops *cr_ops;
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	unsigned long		cr_magic;	/* 0x0f4aa4f0 */
> >  #endif
> >  	unsigned long		cr_expire;	/* when to gc */
> > diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
> > index 7c1ef9530087..b646b3e99666 100644
> > --- a/include/linux/sunrpc/debug.h
> > +++ b/include/linux/sunrpc/debug.h
> > @@ -14,9 +14,6 @@
> >  /*
> >   * Enable RPC debugging/profiling.
> >   */
> > -#ifdef CONFIG_SUNRPC_DEBUG
> > -#define  RPC_DEBUG
> > -#endif
> >  #ifdef CONFIG_TRACEPOINTS
> >  #define RPC_TRACEPOINTS
> >  #endif
> > @@ -25,7 +22,7 @@
> >  /*
> >   * Debugging macros etc
> >   */
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  extern unsigned int		rpc_debug;
> >  extern unsigned int		nfs_debug;
> >  extern unsigned int		nfsd_debug;
> > @@ -36,7 +33,7 @@ extern unsigned int		nlm_debug;
> >  #define dprintk_rcu(args...)	dfprintk_rcu(FACILITY, ## args)
> >  
> >  #undef ifdebug
> > -#ifdef RPC_DEBUG			
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
> >  
> >  # define dfprintk(fac, args...)	\
> > @@ -65,7 +62,7 @@ extern unsigned int		nlm_debug;
> >  /*
> >   * Sysctl interface for RPC debugging
> >   */
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  void		rpc_register_sysctl(void);
> >  void		rpc_unregister_sysctl(void);
> >  int		sunrpc_debugfs_init(void);
> > diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> > index 1a8959944c5f..fecdbf1b4797 100644
> > --- a/include/linux/sunrpc/sched.h
> > +++ b/include/linux/sunrpc/sched.h
> > @@ -79,7 +79,7 @@ struct rpc_task {
> >  	unsigned short		tk_flags;	/* misc flags */
> >  	unsigned short		tk_timeouts;	/* maj timeouts */
> >  
> > -#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
> >  	unsigned short		tk_pid;		/* debugging aid */
> >  #endif
> >  	unsigned char		tk_priority : 2,/* Task priority */
> > @@ -187,7 +187,7 @@ struct rpc_wait_queue {
> >  	unsigned char		nr;			/* # tasks remaining for cookie */
> >  	unsigned short		qlen;			/* total # tasks waiting in queue */
> >  	struct rpc_timer	timer_list;
> > -#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
> >  	const char *		name;
> >  #endif
> >  };
> > @@ -237,7 +237,7 @@ void		rpc_free(void *);
> >  int		rpciod_up(void);
> >  void		rpciod_down(void);
> >  int		__rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_f *);
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  struct net;
> >  void		rpc_show_tasks(struct net *);
> >  #endif
> > @@ -251,7 +251,7 @@ static inline int rpc_wait_for_completion_task(struct rpc_task *task)
> >  	return __rpc_wait_for_completion_task(task, NULL);
> >  }
> >  
> > -#if defined(RPC_DEBUG) || defined (RPC_TRACEPOINTS)
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined (RPC_TRACEPOINTS)
> >  static inline const char * rpc_qname(const struct rpc_wait_queue *q)
> >  {
> >  	return ((q && q->name) ? q->name : "unknown");
> > diff --git a/include/uapi/linux/nfsd/debug.h b/include/uapi/linux/nfsd/debug.h
> > index a6f453c740b8..1fdc95bb2375 100644
> > --- a/include/uapi/linux/nfsd/debug.h
> > +++ b/include/uapi/linux/nfsd/debug.h
> > @@ -15,7 +15,7 @@
> >   * Enable debugging for nfsd.
> >   * Requires RPC_DEBUG.
> >   */
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define NFSD_DEBUG		1
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> > index 383eb919ac0b..47f38be4155f 100644
> > --- a/net/sunrpc/auth.c
> > +++ b/net/sunrpc/auth.c
> > @@ -16,7 +16,7 @@
> >  #include <linux/sunrpc/gss_api.h>
> >  #include <linux/spinlock.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > @@ -646,7 +646,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
> >  	cred->cr_auth = auth;
> >  	cred->cr_ops = ops;
> >  	cred->cr_expire = jiffies;
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	cred->cr_magic = RPCAUTH_CRED_MAGIC;
> >  #endif
> >  	cred->cr_uid = acred->uid;
> > diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
> > index 6f6b829c9e8e..41248b1820c7 100644
> > --- a/net/sunrpc/auth_generic.c
> > +++ b/net/sunrpc/auth_generic.c
> > @@ -14,7 +14,7 @@
> >  #include <linux/sunrpc/debug.h>
> >  #include <linux/sunrpc/sched.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 53ed8d3f8897..dace13d7638e 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -66,7 +66,7 @@ static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
> >  #define GSS_KEY_EXPIRE_TIMEO 240
> >  static unsigned int gss_key_expire_timeo = GSS_KEY_EXPIRE_TIMEO;
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_generic_token.c b/net/sunrpc/auth_gss/gss_generic_token.c
> > index c586e92bcf76..254defe446a7 100644
> > --- a/net/sunrpc/auth_gss/gss_generic_token.c
> > +++ b/net/sunrpc/auth_gss/gss_generic_token.c
> > @@ -38,7 +38,7 @@
> >  #include <linux/sunrpc/gss_asn1.h>
> >  
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > index f5ed9f6ece06..b5408e8a37f2 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> > @@ -45,7 +45,7 @@
> >  #include <linux/sunrpc/gss_krb5.h>
> >  #include <linux/sunrpc/xdr.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
> > index 24589bd2a4b6..234fa8d0fd9b 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_keys.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
> > @@ -61,7 +61,7 @@
> >  #include <linux/sunrpc/xdr.h>
> >  #include <linux/lcm.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> > index 0d3c158ef8fa..28db442a0034 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> > @@ -45,7 +45,7 @@
> >  #include <linux/crypto.h>
> >  #include <linux/sunrpc/gss_krb5_enctypes.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
> > index 42768e5c3994..1d74d653e6c0 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> > @@ -64,7 +64,7 @@
> >  #include <linux/random.h>
> >  #include <linux/crypto.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> > index 62ac90c62cb1..20d55c793eb6 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> > @@ -35,7 +35,7 @@
> >  #include <linux/sunrpc/gss_krb5.h>
> >  #include <linux/crypto.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> > index 6c981ddc19f8..dcf9515d9aef 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> > @@ -62,7 +62,7 @@
> >  #include <linux/sunrpc/gss_krb5.h>
> >  #include <linux/crypto.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index 4b614c604fe0..ca7e92a32f84 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -35,7 +35,7 @@
> >  #include <linux/pagemap.h>
> >  #include <linux/crypto.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> > index 92d5ab99fbf3..7063d856a598 100644
> > --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> > +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> > @@ -46,7 +46,7 @@
> >  #include <linux/sunrpc/gss_api.h>
> >  #include <linux/sunrpc/clnt.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY        RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
> > index 685a688f3d8a..9d88c6239f01 100644
> > --- a/net/sunrpc/auth_gss/gss_rpc_xdr.h
> > +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
> > @@ -25,7 +25,7 @@
> >  #include <linux/sunrpc/clnt.h>
> >  #include <linux/sunrpc/xprtsock.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > index c548ab213f76..de856ddf5fed 100644
> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > @@ -51,7 +51,7 @@
> >  #include "gss_rpc_upcall.h"
> >  
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
> > index 712c123e04e9..c2a2b584a056 100644
> > --- a/net/sunrpc/auth_null.c
> > +++ b/net/sunrpc/auth_null.c
> > @@ -10,7 +10,7 @@
> >  #include <linux/module.h>
> >  #include <linux/sunrpc/clnt.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > @@ -138,7 +138,7 @@ struct rpc_cred null_cred = {
> >  	.cr_ops		= &null_credops,
> >  	.cr_count	= ATOMIC_INIT(1),
> >  	.cr_flags	= 1UL << RPCAUTH_CRED_UPTODATE,
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	.cr_magic	= RPCAUTH_CRED_MAGIC,
> >  #endif
> >  };
> > diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
> > index d5d692366294..4feda2d0a833 100644
> > --- a/net/sunrpc/auth_unix.c
> > +++ b/net/sunrpc/auth_unix.c
> > @@ -25,7 +25,7 @@ struct unx_cred {
> >  
> >  #define UNX_WRITESLACK		(21 + (UNX_MAXNODENAME >> 2))
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_AUTH
> >  #endif
> >  
> > diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> > index 9761a0da964d..651f49ab601f 100644
> > --- a/net/sunrpc/backchannel_rqst.c
> > +++ b/net/sunrpc/backchannel_rqst.c
> > @@ -27,7 +27,7 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> >  #include <linux/export.h>
> >  #include <linux/sunrpc/bc_xprt.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  #define RPCDBG_FACILITY	RPCDBG_TRANS
> >  #endif
> >  
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 5b2e2d3d37c1..dc894facfb69 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -42,7 +42,7 @@
> >  #include "sunrpc.h"
> >  #include "netns.h"
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_CALL
> >  #endif
> >  
> > @@ -1396,7 +1396,7 @@ rpc_restart_call(struct rpc_task *task)
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_restart_call);
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  const char
> >  *rpc_proc_name(const struct rpc_task *task)
> >  {
> > @@ -2422,7 +2422,7 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_call_null);
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  static void rpc_show_header(void)
> >  {
> >  	printk(KERN_INFO "-pid- flgs status -client- --rqstp- "
> > diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> > index 1891a1022c17..05202012bcfc 100644
> > --- a/net/sunrpc/rpcb_clnt.c
> > +++ b/net/sunrpc/rpcb_clnt.c
> > @@ -32,7 +32,7 @@
> >  
> >  #include "netns.h"
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_BIND
> >  #endif
> >  
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index fe3441abdbe5..574b2977fc4b 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -24,7 +24,7 @@
> >  
> >  #include "sunrpc.h"
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  #define RPCDBG_FACILITY		RPCDBG_SCHED
> >  #endif
> >  
> > @@ -258,7 +258,7 @@ static int rpc_wait_bit_killable(struct wait_bit_key *key)
> >  	return 0;
> >  }
> >  
> > -#if defined(RPC_DEBUG) || defined(RPC_TRACEPOINTS)
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
> >  static void rpc_task_set_debuginfo(struct rpc_task *task)
> >  {
> >  	static atomic_t rpc_pid;
> > diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> > index 32583adf3477..e37fbed87956 100644
> > --- a/net/sunrpc/sunrpc_syms.c
> > +++ b/net/sunrpc/sunrpc_syms.c
> > @@ -102,7 +102,7 @@ init_sunrpc(void)
> >  	if (err)
> >  		goto out5;
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	rpc_register_sysctl();
> >  #endif
> >  	svc_init_xprt_sock();	/* svc sock transport */
> > @@ -131,7 +131,7 @@ cleanup_sunrpc(void)
> >  	unregister_rpc_pipefs();
> >  	rpc_destroy_mempool();
> >  	unregister_pernet_subsys(&sunrpc_net_ops);
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	rpc_unregister_sysctl();
> >  #endif
> >  	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index 371a8bbb43d6..2783fd80c229 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1042,7 +1042,7 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
> >  /*
> >   * dprintk the given error with the address of the client that caused it.
> >   */
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  static __printf(2, 3)
> >  void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
> >  {
> > diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> > index c99c58e2ee66..887f0183b4c6 100644
> > --- a/net/sunrpc/sysctl.c
> > +++ b/net/sunrpc/sysctl.c
> > @@ -37,7 +37,7 @@ EXPORT_SYMBOL_GPL(nfsd_debug);
> >  unsigned int	nlm_debug;
> >  EXPORT_SYMBOL_GPL(nlm_debug);
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  
> >  static struct ctl_table_header *sunrpc_table_header;
> >  static struct ctl_table sunrpc_table[];
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 1b2e5e616cae..894d071426b2 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -57,7 +57,7 @@
> >   * Local variables
> >   */
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_XPRT
> >  #endif
> >  
> > diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> > index 6166c985fe24..df01d124936c 100644
> > --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> > +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> > @@ -49,11 +49,11 @@
> >  
> >  #include <linux/highmem.h>
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_TRANS
> >  #endif
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  static const char transfertypes[][12] = {
> >  	"pure inline",	/* no chunks */
> >  	" read chunk",	/* some argument via rdma read */
> > diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> > index 6a4615dd0261..ef58ebadb3ae 100644
> > --- a/net/sunrpc/xprtrdma/transport.c
> > +++ b/net/sunrpc/xprtrdma/transport.c
> > @@ -55,7 +55,7 @@
> >  
> >  #include "xprt_rdma.h"
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_TRANS
> >  #endif
> >  
> > @@ -75,7 +75,7 @@ static unsigned int xprt_rdma_inline_write_padding;
> >  static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
> >                  int xprt_rdma_pad_optimize = 0;
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  
> >  static unsigned int min_slot_table_size = RPCRDMA_MIN_SLOT_TABLE;
> >  static unsigned int max_slot_table_size = RPCRDMA_MAX_SLOT_TABLE;
> > @@ -705,7 +705,7 @@ static void __exit xprt_rdma_cleanup(void)
> >  	int rc;
> >  
> >  	dprintk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	if (sunrpc_table_header) {
> >  		unregister_sysctl_table(sunrpc_table_header);
> >  		sunrpc_table_header = NULL;
> > @@ -736,7 +736,7 @@ static int __init xprt_rdma_init(void)
> >  	dprintk("\tPadding %d\n\tMemreg %d\n",
> >  		xprt_rdma_inline_write_padding, xprt_rdma_memreg_strategy);
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	if (!sunrpc_table_header)
> >  		sunrpc_table_header = register_sysctl_table(sunrpc_table);
> >  #endif
> > diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> > index 61c41298b4ea..b92b04083e40 100644
> > --- a/net/sunrpc/xprtrdma/verbs.c
> > +++ b/net/sunrpc/xprtrdma/verbs.c
> > @@ -57,7 +57,7 @@
> >   * Globals/Macros
> >   */
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # define RPCDBG_FACILITY	RPCDBG_TRANS
> >  #endif
> >  
> > @@ -313,7 +313,7 @@ rpcrdma_flush_cqs(struct rpcrdma_ep *ep)
> >  	rpcrdma_sendcq_upcall(ep->rep_attr.send_cq, ep);
> >  }
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  static const char * const conn[] = {
> >  	"address resolved",
> >  	"address error",
> > @@ -344,7 +344,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
> >  	struct rpcrdma_xprt *xprt = id->context;
> >  	struct rpcrdma_ia *ia = &xprt->rx_ia;
> >  	struct rpcrdma_ep *ep = &xprt->rx_ep;
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	struct sockaddr_in *addr = (struct sockaddr_in *) &ep->rep_remote_addr;
> >  #endif
> >  	struct ib_qp_attr attr;
> > @@ -408,7 +408,7 @@ connected:
> >  		break;
> >  	}
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	if (connstate == 1) {
> >  		int ird = attr.max_dest_rd_atomic;
> >  		int tird = ep->rep_remote_cma.responder_resources;
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 31c015196a29..87ce7e8bb8dc 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -75,7 +75,7 @@ static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
> >   * someone else's file names!
> >   */
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  
> >  static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
> >  static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
> > @@ -186,7 +186,7 @@ static struct ctl_table sunrpc_table[] = {
> >   */
> >  #define XS_IDLE_DISC_TO		(5U * 60 * HZ)
> >  
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  # undef  RPC_DEBUG_DATA
> >  # define RPCDBG_FACILITY	RPCDBG_TRANS
> >  #endif
> > @@ -2991,7 +2991,7 @@ static struct xprt_class	xs_bc_tcp_transport = {
> >   */
> >  int init_socket_xprt(void)
> >  {
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	if (!sunrpc_table_header)
> >  		sunrpc_table_header = register_sysctl_table(sunrpc_table);
> >  #endif
> > @@ -3010,7 +3010,7 @@ int init_socket_xprt(void)
> >   */
> >  void cleanup_socket_xprt(void)
> >  {
> > -#ifdef RPC_DEBUG
> > +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> >  	if (sunrpc_table_header) {
> >  		unregister_sysctl_table(sunrpc_table_header);
> >  		sunrpc_table_header = NULL;
> 


-- 
Jeff Layton <jlayton@primarydata.com>
