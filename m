Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:59170 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab2LCWso convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 17:48:44 -0500
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id qB3Md3rP026689
	for <linux-nfs@vger.kernel.org>; Mon, 3 Dec 2012 14:39:04 -0800 (PST)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: new keyring key_type for gss context
 destruction at kdestroy
Date: Mon, 3 Dec 2012 22:39:02 +0000
Message-ID: <7851A663D3BF5E41B9E166C2C7A42145104F61E8@SACEXCMBX02-PRD.hq.netapp.com>
References: <1354560315-2393-1-git-send-email-andros@netapp.com>
 <1354560315-2393-2-git-send-email-andros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B334027@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B334027@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 3, 2012, at 4:06 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Mon, 2012-12-03 at 13:45 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> This code works in conjunction with nfslogin and nfslogout programs
>> which enforce the use of the keyring Kerberos credential cache of the
>> form KEYRING:krb5cc_<UID> and adds a gss-ctx key to the krb5cc_<UID> keyring.
>> 
>> When kdestroy is called on the keyring context the .destroy function of the
>> new key is called which marks all gss_context's associated with the UID as
>> out of date.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> net/sunrpc/auth_gss/auth_gss.c |   85 ++++++++++++++++++++++++++++++++++++++++
>> 1 files changed, 85 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
>> index 082e579..2d8fbf1 100644
>> --- a/net/sunrpc/auth_gss/auth_gss.c
>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>> @@ -51,6 +51,12 @@
>> #include <linux/sunrpc/rpc_pipe_fs.h>
>> #include <linux/sunrpc/gss_api.h>
>> #include <asm/uaccess.h>
>> +#include <linux/key.h>
>> +#include <linux/keyctl.h>
>> +#include <linux/key-type.h>
>> +#include <keys/user-type.h>
>> +
>> +#include "../netns.h"
>> 
>> static const struct rpc_authops authgss_ops;
>> 
>> @@ -95,6 +101,83 @@ static void gss_free_ctx(struct gss_cl_ctx *);
>> static const struct rpc_pipe_ops gss_upcall_ops_v0;
>> static const struct rpc_pipe_ops gss_upcall_ops_v1;
>> 
>> +/*
>> + * Search all rpc_clnt auth's and invalidate any RPC_AUT_GSS Kerberos
>> + * gss contexts belonging to uid. Triggered by kdestroy of keyring
>> + * kerberos credentials.
>> + */
>> +static void
>> +gss_kdestroy_cred(uid_t uid)
>> +{
>> +	struct net *net = current->nsproxy->net_ns;
>> +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>> +	struct rpc_clnt *clnt;
>> +	struct rpc_cred *cr;
>> +	struct auth_cred ac = {
>> +		.uid = uid,
>> +	};
>> +
>> +	dprintk("--> %s uid %d\n", __func__, uid);
>> +	spin_lock(&sn->rpc_client_lock);
>> +	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
>> +		if ((clnt->cl_auth->au_flavor == RPC_AUTH_GSS_KRB5) ||
>> +		    (clnt->cl_auth->au_flavor == RPC_AUTH_GSS_KRB5I) ||
>> +		    (clnt->cl_auth->au_flavor == RPC_AUTH_GSS_KRB5P)) {
>> +			cr = rpcauth_lookup_credcache(clnt->cl_auth, &ac, 0);
>> +			if (IS_ERR(cr) || cr == NULL)
>> +				continue;
>> +			dprintk("%s invalidated cred %p from auth %p crcache\n",
>> +				 __func__, cr, clnt->cl_auth);
>> +			smp_mb__before_clear_bit();
>> +			clear_bit(RPCAUTH_CRED_UPTODATE, &cr->cr_flags);
>> +			smp_mb__after_clear_bit();
>> +			put_rpccred(cr); /* balance get in lookup credcache */
>> +		}
>> +	}
>> +	spin_unlock(&sn->rpc_client_lock);
>> +}
>> +
>> +static void
>> +gss_user_destroy(struct key *key)
>> +{
>> +	struct user_key_payload *upayload;
>> +	int uid = 0;
>> +
>> +	upayload = rcu_dereference_key(key);
>> +	memcpy((void *)&uid, upayload->data, sizeof(int));
> 
> It seems to me that this code allows me to kill anyone's rpcsec_gss
> sessions by creating a key with their uid, and then destroying it.

Yes - just proof of concept code. There is a lot to consider.

> 
> One solution is to replace user_instantiate() with something that sets
> the payload to a value determined by the kernel itself. We'd definitely
> want to include the uid, but perhaps also add a cookie that is unique to
> this key (using the idr/ida stuff from include/linux/idr.h ?), and that
> can be used to distinguish it from keys generated from other processes.
> If we were to use the same key to label the auth_gss creds, then we
> could have user_gss_destroy() kill _only_ the auth_gss creds that it
> spawned.

Yes, killing only the auth it spawned is indeed what we want.

> 
> Ultimately, though, I think we might want to let the user set at least
> _part_ of the payload to something that might be useful to gssd when it
> goes looking for credentials. Since the nfslogin and gssd will be
> shipped as part of the nfs-utils package, it would be nice to allow them
> to use the gss-ctx key in order to communicate. Interesting information
> might include the KRB5CCNAME.

Thanks for the good suggestions.

-->Andy


> 
>> +	gss_kdestroy_cred((uid_t)uid);
>> +	return user_destroy(key);
>> +}
>> +
>> +static struct key_type key_type_gss_ctx = {
>> +	.name		= "gss-ctx",
>> +	.instantiate	= user_instantiate,
>> +	.match		= user_match,
>> +	.revoke		= user_revoke,
>> +	.destroy	= gss_user_destroy,
>> +	.describe	= user_describe,
>> +	.read		= user_read,
>> +};
>> +
>> +
>> +/* Register the gss-ctx key type for use by nfslogin and nfslogout */
>> +static int gss_register_ctx_keytype(void)
>> +{
>> +	int ret;
>> +
>> +	ret = register_key_type(&key_type_gss_ctx);
>> +
>> +	pr_notice("NFS: Registering the %s key type ret %d\n",
>> +		key_type_gss_ctx.name, ret);
>> +
>> +	return ret;
>> +}
>> +
>> +static void gss_unregister_ctx_keytype(void)
>> +{
>> +	unregister_key_type(&key_type_gss_ctx);
>> +}
>> +
>> static inline struct gss_cl_ctx *
>> gss_get_ctx(struct gss_cl_ctx *ctx)
>> {
>> @@ -1748,6 +1831,7 @@ static int __init init_rpcsec_gss(void)
>> 	if (err)
>> 		goto out_svc_exit;
>> 	rpc_init_wait_queue(&pipe_version_rpc_waitqueue, "gss pipe version");
>> +	gss_register_ctx_keytype();
>> 	return 0;
>> out_svc_exit:
>> 	gss_svc_shutdown();
>> @@ -1762,6 +1846,7 @@ static void __exit exit_rpcsec_gss(void)
>> 	unregister_pernet_subsys(&rpcsec_gss_net_ops);
>> 	gss_svc_shutdown();
>> 	rpcauth_unregister(&authgss_ops);
>> +	gss_unregister_ctx_keytype();
>> 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>> }
>> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

