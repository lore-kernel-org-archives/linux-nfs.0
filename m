Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D39EB397691;
	Fri, 18 Sep 2026 14:45:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789742720; cv=none; b=VHlLDpjpR6qkxUQxNVEu40czVi1sZxs3CX1IxrljgthEfNlV1lkoRTBY20qszwPsVSfNQdIzXJWditYTP0K8FFSkklriSvPS7TC412fZgRePRGSM44IINxqryZOkdxfCfn8seCCeXyDI5td85y2Rpl2Hjg7X9GRZpH5miC+wkl8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789742720; c=relaxed/simple;
	bh=rGTov9lEabDQJI6s0tqmkKQoMdfh7wPxKbbumW0fPwM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=lLlnAbxhPaV+WxIshY2sw/ofmf+7mA4zZPkuNF/H8FkZf4tgsiUjh+eD7HHCya4c/Cx10rjdDMriklDbkPgZKLiDKD352t8QHs/vTikAEtR6qmiYDO969lub6iRSloWVlqKHwGzzCtdDRQ9QPQ2jLozV4f+RlRC1l0GtFWaPoHE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=Q+vDJ55Y; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=mffIaaZD; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=bqrgQVLA; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=k1xV1d6y; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="Q+vDJ55Y";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="mffIaaZD";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="bqrgQVLA";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="k1xV1d6y"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id BE64221BDC;
	Fri, 18 Sep 2026 14:45:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789742711; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ouZbQb+FG4WGxOgRLBY+fRM/c3UqtSaByCtCgTRHDGs=;
	b=Q+vDJ55YNjOd4xRkTSct8mvIAIz286//DXSG52djhT3qT7nRMhB9qKcEYXF34kRSi+Or0G
	H5si3xlhbO40PgsXusH8ZLQmRhsoMaVtoq+gUMMC/slPHdpWUHa0D5Zv96+ecmS/xAT9r4
	hdPhh3RHzep87R6CaOmyfnxKZRWSbA4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789742711;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ouZbQb+FG4WGxOgRLBY+fRM/c3UqtSaByCtCgTRHDGs=;
	b=mffIaaZDJcrfOHt6v5pYWxkUBw1NmqyBOaZHLvsVVUJsR0c2wFfk72or23kyIl/wwA9MHQ
	YkVomXfDNMbydIDQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789742707; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ouZbQb+FG4WGxOgRLBY+fRM/c3UqtSaByCtCgTRHDGs=;
	b=bqrgQVLAfoGoh/zKY4bQi6Izfi+HO/zEIBNZHWIzo8P+T5OKdS+Sh7N549D5gMsVvalr1O
	e0FFYe60G3wif6UONY9raOPUZSqOHttd2TAjpABdK+Efd3uMOoBEawNwNwgTYpselsmc52
	Ox6HauardNJ3i9ys5P5/G0MYAgz6XN0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789742707;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ouZbQb+FG4WGxOgRLBY+fRM/c3UqtSaByCtCgTRHDGs=;
	b=k1xV1d6yvCtfFIzYLk86SicjuUHtiaF6YLf+Te52QyTIbU5lD1ehHaOjguztxsIfiw4G7O
	L0cdKinsoPwFBDBg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 3031D133CF;
	Fri, 18 Sep 2026 14:45:07 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id CsW5AXNOrWqUDwAAD6G6ig
	(envelope-from <hare@suse.de>); Fri, 18 Sep 2026 14:45:07 +0000
Message-ID: <bbc4ff6f-aa38-4862-96fe-518c3b4df4d6@suse.de>
Date: Fri, 18 Sep 2026 16:44:50 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 2/5] NFS: allocate the .nfs keyring per network
 namespace
To: Chuck Lever <cel@kernel.org>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>,
 Randy Dunlap <rdunlap@infradead.org>, Christian Brauner
 <brauner@kernel.org>, David Howells <dhowells@redhat.com>,
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <20260918-nfs-mtls-identity-v1-2-197e568d78a7@kernel.org>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260918-nfs-mtls-identity-v1-2-197e568d78a7@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Score: -4.30
X-Spam-Level: 
X-Spamd-Result: default: False [-4.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-0.996];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[19];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:mid,suse.de:email]
X-Spam-Flag: NO

On 9/18/26 4:05 PM, Chuck Lever wrote:
> Commit 87268f7a4f1f ("nfs: create a kernel keyring") allocates one
> .nfs keyring at module load, and nothing in the NFS client reads it.
> One module-wide keyring also cannot isolate x.509 credentials
> between network namespaces. Each tlshd instance services the
> handshake socket of one network namespace, so a credential
> provisioned for that namespace's mounts has to be reachable by that
> tlshd and by no other.
> 
> Allocate one .nfs keyring per network namespace in nfs_net_init()
> and release it in nfs_net_exit(). tlshd finds a keyring by name
> through /proc/keys, which is not namespace scoped, so each handshake
> request has to carry the keyring serial instead. Allocate the
> keyring under a kernel credential rather than that of the task
> creating the namespace, so an LSM labels every namespace's keyring
> the same way.
> 
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>   fs/nfs/inode.c | 81 +++++++++++++++++++++++++++++++---------------------------
>   fs/nfs/netns.h |  2 ++
>   2 files changed, 46 insertions(+), 37 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 832923be43a9..bd327fbb12d8 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -2641,11 +2641,50 @@ static int nfsiod_start(void)
>   unsigned int nfs_net_id;
>   EXPORT_SYMBOL_GPL(nfs_net_id);
>   
> +#ifdef CONFIG_KEYS
> +static int nfs_init_keyring(struct nfs_net *nn)
> +{
> +	struct cred *cred;
> +	struct key *keyring;
> +
> +	cred = prepare_kernel_cred(&init_task);
> +	if (!cred)
> +		return -ENOMEM;
> +	keyring = keyring_alloc(".nfs", GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
> +				(KEY_POS_ALL & ~KEY_POS_SETATTR) |
> +				(KEY_USR_ALL & ~KEY_USR_SETATTR),
> +				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
> +	put_cred(cred);
> +	if (IS_ERR(keyring))
> +		return PTR_ERR(keyring);
> +	nn->nfs_keyring = keyring;
> +	return 0;
> +}
> +
> +static void nfs_exit_keyring(struct nfs_net *nn)
> +{
> +	key_put(nn->nfs_keyring);
> +}
> +#else
> +static inline int nfs_init_keyring(struct nfs_net *nn)
> +{
> +	return 0;
> +}
> +
> +static inline void nfs_exit_keyring(struct nfs_net *nn)
> +{
> +}
> +#endif /* CONFIG_KEYS */
> +
>   static int nfs_net_init(struct net *net)
>   {
>   	struct nfs_net *nn = net_generic(net, nfs_net_id);
>   	int err;
>   
> +	err = nfs_init_keyring(nn);
> +	if (err)
> +		return err;
> +
>   	nfs_clients_init(net);
>   
>   	if (!rpc_proc_register(net, &nn->rpcstats)) {
> @@ -2663,14 +2702,18 @@ static int nfs_net_init(struct net *net)
>   	rpc_proc_unregister(net, "nfs");
>   err_proc_rpc:
>   	nfs_clients_exit(net);
> +	nfs_exit_keyring(nn);
>   	return err;
>   }
>   
>   static void nfs_net_exit(struct net *net)
>   {
> +	struct nfs_net *nn = net_generic(net, nfs_net_id);
> +
>   	rpc_proc_unregister(net, "nfs");
>   	nfs_fs_proc_net_exit(net);
>   	nfs_clients_exit(net);
> +	nfs_exit_keyring(nn);
>   }
>   
>   static struct pernet_operations nfs_net_ops = {
> @@ -2680,35 +2723,6 @@ static struct pernet_operations nfs_net_ops = {
>   	.size = sizeof(struct nfs_net),
>   };
>   
> -#ifdef CONFIG_KEYS
> -static struct key *nfs_keyring;
> -
> -static int __init nfs_init_keyring(void)
> -{
> -	nfs_keyring = keyring_alloc(".nfs",
> -			     GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
> -			     current_cred(),
> -			     (KEY_POS_ALL & ~KEY_POS_SETATTR) |
> -			     (KEY_USR_ALL & ~KEY_USR_SETATTR),
> -			     KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
> -	return PTR_ERR_OR_ZERO(nfs_keyring);
> -}
> -
> -static void nfs_exit_keyring(void)
> -{
> -	key_put(nfs_keyring);
> -}
> -#else
> -static inline int nfs_init_keyring(void)
> -{
> -	return 0;
> -}
> -
> -static inline void nfs_exit_keyring(void)
> -{
> -}
> -#endif /* CONFIG_KEYS */
> -
>   /*
>    * Initialize NFS
>    */
> @@ -2716,13 +2730,9 @@ static int __init init_nfs_fs(void)
>   {
>   	int err;
>   
> -	err = nfs_init_keyring();
> -	if (err)
> -		return err;
> -
>   	err = nfs_sysfs_init();
>   	if (err < 0)
> -		goto err_keyring;
> +		return err;
>   
>   	err = register_pernet_subsys(&nfs_net_ops);
>   	if (err < 0)
> @@ -2779,8 +2789,6 @@ static int __init init_nfs_fs(void)
>   	unregister_pernet_subsys(&nfs_net_ops);
>   err_sysfs:
>   	nfs_sysfs_exit();
> -err_keyring:
> -	nfs_exit_keyring();
>   	return err;
>   }
>   
> @@ -2796,7 +2804,6 @@ static void __exit exit_nfs_fs(void)
>   	nfs_fs_proc_exit();
>   	nfsiod_stop();
>   	nfs_sysfs_exit();
> -	nfs_exit_keyring();
>   }
>   
>   /* Not quite true; I just maintain it */
> diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
> index 36658579100d..da0854510404 100644
> --- a/fs/nfs/netns.h
> +++ b/fs/nfs/netns.h
> @@ -16,6 +16,7 @@ struct bl_dev_msg {
>   	uint32_t major, minor;
>   };
>   
> +struct key;
>   struct nfs_netns_client;
>   
>   struct nfs_net {
> @@ -36,6 +37,7 @@ struct nfs_net {
>   #endif /* CONFIG_NFS_V4 */
>   	struct nfs_netns_client *nfs_client;
>   	spinlock_t nfs_client_lock;
> +	struct key *nfs_keyring;
>   	ktime_t boot_time;
>   	struct rpc_stat rpcstats;
>   #ifdef CONFIG_PROC_FS
> 
Curiously enough, I had been pondering a similar issue.
Thing is, when running within a container (eg a docker one) access
access to /proc/keys might be restricted, and from what I've
gathered each container gets its own, _empty_ keyring.
(certainly an empty session keyring ...).
So I wonder what'll happen with the predefined keyrings (like the
.nvme keyring); one possibility is surely to make them network
namespace aware.
But the alternative approach I'm exploring is to allow each container
to create its own (.nvme) keyring; that would have the advantage of
being more flexible and we wouldn't need to rely on 'magic' names.

Hmm?

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
