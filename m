Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:1267 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389368AbeG0WNX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Jul 2018 18:13:23 -0400
Subject: Re: [PATCH PATCH net-next 15/18] sunrpc: whitespace fixes
To: Stephen Hemminger <stephen@networkplumber.org>,
        <davem@davemloft.net>, <ericvh@gmail.com>, <rminnich@sandia.gov>,
        <lucho@ionkov.net>, <ralf@linux-mips.org>, <jreuter@yaina.de>,
        <pablo@netfilter.org>, <kadlec@blackhole.kfki.hu>, <fw@strlen.de>,
        <alex.aring@gmail.com>, <stefan@datenfreihafen.org>,
        <kuznet@ms2.inr.ac.ru>, <yoshfuji@linux-ipv6.org>,
        <johannes@sipsolutions.net>, <jhs@mojatatu.com>,
        <xiyou.wangcong@gmail.com>, <jiri@resnulli.us>,
        <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
        <marcelo.leitner@gmail.com>, <trond.myklebust@hammerspace.com>,
        <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
CC: <netdev@vger.kernel.org>, <v9fs-developer@lists.sourceforge.net>,
        <linux-hams@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
        <linux-decnet-user@lists.sourceforge.net>,
        <netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
        <linux-wpan@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linux-sctp@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-x25@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
 <20180724192918.31165-16-sthemmin@microsoft.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <c4ca53ea-80d8-9fa1-15ce-ce9c5e4bc6ac@Netapp.com>
Date: Fri, 27 Jul 2018 16:39:39 -0400
MIME-Version: 1.0
In-Reply-To: <20180724192918.31165-16-sthemmin@microsoft.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/24/2018 03:29 PM, Stephen Hemminger wrote:
> Remove trailing whitespace and blank line at EOF

Looks good to me, I've applied it to my tree.

Thanks!
Anna

> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  net/sunrpc/auth_gss/auth_gss.c          | 2 +-
>  net/sunrpc/auth_gss/gss_generic_token.c | 1 -
>  net/sunrpc/auth_gss/gss_krb5_crypto.c   | 1 -
>  net/sunrpc/auth_gss/gss_krb5_keys.c     | 1 -
>  net/sunrpc/auth_gss/gss_krb5_seal.c     | 1 -
>  net/sunrpc/auth_gss/gss_krb5_unseal.c   | 1 -
>  net/sunrpc/auth_gss/gss_krb5_wrap.c     | 1 -
>  net/sunrpc/auth_gss/svcauth_gss.c       | 2 +-
>  net/sunrpc/backchannel_rqst.c           | 1 -
>  net/sunrpc/clnt.c                       | 2 +-
>  net/sunrpc/rpcb_clnt.c                  | 2 +-
>  net/sunrpc/stats.c                      | 1 -
>  net/sunrpc/sunrpc.h                     | 1 -
>  net/sunrpc/xprt.c                       | 2 +-
>  net/sunrpc/xprtsock.c                   | 1 -
>  15 files changed, 5 insertions(+), 15 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index be8f103d22fd..b67ad98a36a6 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1571,7 +1571,7 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
>  	if (test_bit(RPCAUTH_CRED_NEGATIVE, &cred->cr_flags)) {
>  		unsigned long now = jiffies;
>  		unsigned long begin, expire;
> -		struct gss_cred *gss_cred; 
> +		struct gss_cred *gss_cred;
>  
>  		gss_cred = container_of(cred, struct gss_cred, gc_base);
>  		begin = gss_cred->gc_upcall_timestamp;
> diff --git a/net/sunrpc/auth_gss/gss_generic_token.c b/net/sunrpc/auth_gss/gss_generic_token.c
> index 254defe446a7..fe97f3106536 100644
> --- a/net/sunrpc/auth_gss/gss_generic_token.c
> +++ b/net/sunrpc/auth_gss/gss_generic_token.c
> @@ -231,4 +231,3 @@ g_verify_token_header(struct xdr_netobj *mech, int *body_size,
>  }
>  
>  EXPORT_SYMBOL_GPL(g_verify_token_header);
> -
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 8654494b4d0a..a1acee106faa 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -1077,4 +1077,3 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
>  	dprintk("%s: returning %d\n", __func__, err);
>  	return err;
>  }
> -
> diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
> index 870133146026..f7fe2d2b851f 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_keys.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
> @@ -324,4 +324,3 @@ u32 gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
>  err_out:
>  	return ret;
>  }
> -
> diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
> index 94a2b3f082a8..eaad9bc7a0bd 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> @@ -229,4 +229,3 @@ gss_get_mic_kerberos(struct gss_ctx *gss_ctx, struct xdr_buf *text,
>  		return gss_get_mic_v2(ctx, text, token);
>  	}
>  }
> -
> diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> index b601a73cc9db..ef2b25b86d2f 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> @@ -225,4 +225,3 @@ gss_verify_mic_kerberos(struct gss_ctx *gss_ctx,
>  		return gss_verify_mic_v2(ctx, message_buffer, read_token);
>  	}
>  }
> -
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index a737c2da0837..286fd22404f2 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -623,4 +623,3 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
>  		return gss_unwrap_kerberos_v2(kctx, offset, buf);
>  	}
>  }
> -
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 5089dbb96d58..860f2a1bbb67 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1389,7 +1389,7 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net)
>  	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>  
>  	if (sn->use_gssp_proc) {
> -		remove_proc_entry("use-gss-proxy", sn->proc_net_rpc); 
> +		remove_proc_entry("use-gss-proxy", sn->proc_net_rpc);
>  		clear_gssp_clnt(sn);
>  	}
>  }
> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> index c2c68a15b59d..3c15a99b9700 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -362,4 +362,3 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
>  	wake_up(&bc_serv->sv_cb_waitq);
>  	spin_unlock(&bc_serv->sv_cb_lock);
>  }
> -
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index d839c33ae7d9..3818e4d55c66 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -892,7 +892,7 @@ rpc_free_client(struct rpc_clnt *clnt)
>  /*
>   * Free an RPC client
>   */
> -static struct rpc_clnt * 
> +static struct rpc_clnt *
>  rpc_free_auth(struct rpc_clnt *clnt)
>  {
>  	if (clnt->cl_auth == NULL)
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index c526f8fb37c9..c7872bc13860 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -213,7 +213,7 @@ static void rpcb_set_local(struct net *net, struct rpc_clnt *clnt,
>  	sn->rpcb_local_clnt = clnt;
>  	sn->rpcb_local_clnt4 = clnt4;
>  	sn->rpcb_is_af_local = is_af_local ? 1 : 0;
> -	smp_wmb(); 
> +	smp_wmb();
>  	sn->rpcb_users = 1;
>  	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt: "
>  		"%p, rpcb_local_clnt4: %p) for net %x%s\n",
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index f68aa46c9dd7..86f316503c7c 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -310,4 +310,3 @@ void rpc_proc_exit(struct net *net)
>  	dprintk("RPC:       unregistering /proc/net/rpc\n");
>  	remove_proc_entry("rpc", net->proc_net);
>  }
> -
> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
> index 09a0315ea77b..c9bacb3c930f 100644
> --- a/net/sunrpc/sunrpc.h
> +++ b/net/sunrpc/sunrpc.h
> @@ -57,4 +57,3 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
>  int rpc_clients_notifier_register(void);
>  void rpc_clients_notifier_unregister(void);
>  #endif /* _NET_SUNRPC_SUNRPC_H */
> -
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3fabf9f6a0f9..a8db2e3f8904 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -880,7 +880,7 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
>  __must_hold(&req->rq_xprt->recv_lock)
>  {
>  	struct rpc_task *task = req->rq_task;
> -	
> +
>  	if (task && test_bit(RPC_TASK_MSG_RECV, &task->tk_runstate)) {
>  		spin_unlock(&req->rq_xprt->recv_lock);
>  		set_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 9e1c5024aba9..6b7539c0466e 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -3375,4 +3375,3 @@ module_param_named(tcp_max_slot_table_entries, xprt_max_tcp_slot_table_entries,
>  		   max_slot_table_size, 0644);
>  module_param_named(udp_slot_table_entries, xprt_udp_slot_table_entries,
>  		   slot_table_size, 0644);
> -
> 
