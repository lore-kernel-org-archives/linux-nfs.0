Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A470F43A7FC;
	Mon, 17 Aug 2026 13:31:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786973479; cv=none; b=AIzK5yuI6NgfmDN4MQpLSpD89OUES+/JeFGb1j0cHcwVPXut8RLPkuhdy5wJ4EfZ46wNl9gBSEAJslwrv8+66YxnmJtU1iyKkwtzPKEpUHQ1+lUx10NBE/+u1MWS5PbihT212UeCenrcVL9hvPEMY0sT69Ws9X5f49az5vssblc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786973479; c=relaxed/simple;
	bh=ED5Qg0LYVn7hEZ/2Si8nDrmTYjtnEaK2CGulku8nQxI=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Ebx4y41z2Ec4NLBnyy19ajNFLWZmMP0XffyucYowfa5A78+8QjxyJGkw+iwiqWDeM/aDHuWWwOfRqrGV7DHCtBKrBxBByQiWqCBbjsoZrrN7kwmCfU8MCBt69iMEKhfEfQw+KJmRO10x5pDZt7YCJ4BrgzGT3+rrLQywVzp897o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WdFhCiYI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WdFhCiYI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6CC031F000E9;
	Mon, 17 Aug 2026 13:31:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786973474;
	bh=cIxHbbJeI7a+/HWpA4JHUC1g6JD670pmSICI8yfcke0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=WdFhCiYI2ZwXtlbSQ9o25m8hLjiTvc8lmbyo64uw0vpiSmLPcihjJkYhIf5vqBUU1
	 /qazx40EWMse4Mbgp7elOf6rWBrsavW10cTD0MK8iWddqgKk2iiFs0Ar5YwaExhP4o
	 LJZjFNTki0GB698Ism32PelmgnmZilHYoVoLcFSaVuJtWMt2IyMEInY8tUy2KJNK0h
	 jrYZB2SM3jBF/bdf9y3bozTIZNi8HFNkeHr4q4gx3k/+8n9fVAgCDYekNtwnEMhlng
	 03mzuI1Z07yk16SK8Ojmhvzk8jlzIeUCLnrL5Bm5AtAJeMpMMvWBwRBh7Fi97E08cq
	 SWVCOhLZ3gHyw==
Message-ID: <4a3a7a0cd52e8fc571c967716756f49b8a0f95f2.camel@kernel.org>
Subject: Re: [PATCH] SUNRPC: update clnt->pipefs_sb on pipefs MOUNT/UMOUNT
 events
From: Jeff Layton <jlayton@kernel.org>
To: Shigeru Yoshida <syoshida@redhat.com>, Trond Myklebust
 <trondmy@kernel.org>,  Anna Schumaker	 <anna@kernel.org>, Chuck Lever
 <cel@kernel.org>, NeilBrown <neil@brown.name>,  Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, "David S. Miller"	 <davem@davemloft.net>, Eric Dumazet
 <edumazet@google.com>, Jakub Kicinski	 <kuba@kernel.org>, Paolo Abeni
 <pabeni@redhat.com>, Simon Horman	 <horms@kernel.org>, felix
 <fuzhen5@huawei.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Mon, 17 Aug 2026 09:31:12 -0400
In-Reply-To: <20260817080013.564939-1-syoshida@redhat.com>
References: <20260817080013.564939-1-syoshida@redhat.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-08-17 at 17:00 +0900, Shigeru Yoshida wrote:
> Commit bfca5fb4e97c ("SUNRPC: Fix RPC client cleaned up the freed
> pipefs dentries") added a clnt->pipefs_sb field and a consistency
> check in rpc_clnt_remove_pipedir() so that pipedir cleanup is skipped
> when the current superblock does not match the one recorded in the
> client.
>=20
> However, __rpc_clnt_handle_event() never updates clnt->pipefs_sb when
> it creates or removes pipedirs in response to RPC_PIPEFS_MOUNT and
> RPC_PIPEFS_UMOUNT notifications.
>=20
> This causes a problem for RPC clients that are registered before
> rpc_pipefs is mounted (e.g., before rpc_pipefs is mounted during boot,
> or after it has been unmounted). Such clients have clnt->pipefs_sb set
> to NULL at registration time because rpc_get_sb_net() returns NULL.
> When rpc_pipefs is mounted later, __rpc_clnt_handle_event(MOUNT)
> creates the pipedir but leaves clnt->pipefs_sb as NULL. When the
> client is later destroyed, rpc_clnt_remove_pipedir() sees that the
> current superblock does not match clnt->pipefs_sb and skips cleanup,
> leaving orphaned dentries whose RPC_I(inode)->private pointers
> reference freed rpc_clnt memory. Any subsequent access to these
> orphaned info files triggers a use-after-free [1].
>=20
> Fix this by setting clnt->pipefs_sb in __rpc_clnt_handle_event() on
> MOUNT and clearing it on UMOUNT, mirroring what rpc_setup_pipedir()
> already does at client registration time.
>=20
> [1]
> BUG: KASAN: slab-use-after-free in rpc_info_open (net/sunrpc/rpc_pipe.c:4=
26)
> Read of size 4 at addr ffff88802ebe0800 by task cat/5079
>=20
> Call Trace:
>  <TASK>
>  ...
>  rpc_info_open (net/sunrpc/rpc_pipe.c:426)
>  do_dentry_open (fs/open.c:947)
>  vfs_open (fs/open.c:1052)
>  path_openat (fs/namei.c:4700 fs/namei.c:4863)
>  do_file_open (fs/namei.c:4892)
>  do_sys_openat2 (fs/open.c:1368)
>  __x64_sys_openat (fs/open.c:1385)
>  do_syscall_64 (arch/x86/entry/syscall_64.c:94)
>  entry_SYSCALL_64_after_hwframe (arch/x86/entry/entry_64.S:121)
>  </TASK>
>=20
> Allocated by task 5048:
>  ...
>  rpc_new_client (net/sunrpc/clnt.c:377)
>  __rpc_clone_client (net/sunrpc/clnt.c:645)
>  rpc_clone_client_set_auth (net/sunrpc/clnt.c:706)
>  nfs_init_server_rpcclient (fs/nfs/client.c:640)
>  nfs_clone_server (fs/nfs/client.c:1247)
>  nfs4_clone_server (fs/nfs/nfs4proc.c:10683)
>  nfs_do_submount (fs/nfs/namespace.c:288)
>  ...
>=20
> Freed by task 24:
>  ...
>  kfree (mm/slub.c:6692)
>  rpc_free_client_work (net/sunrpc/clnt.c:987)
>  process_scheduled_works (kernel/workqueue.c:3405)
>  worker_thread (kernel/workqueue.c:3486)
>  ...
>=20
> Fixes: bfca5fb4e97c ("SUNRPC: Fix RPC client cleaned up the freed pipefs =
dentries")
> Assisted-by: Claude:claude-opus-4-6
> Signed-off-by: Shigeru Yoshida <syoshida@redhat.com>
> ---
>  net/sunrpc/clnt.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index efa26899bc7d..55617d263d2f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -179,11 +179,17 @@ static int rpc_clnt_skip_event(struct rpc_clnt *cln=
t, unsigned long event)
>  static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long =
event,
>  				   struct super_block *sb)
>  {
> +	int err;
> +
>  	switch (event) {
>  	case RPC_PIPEFS_MOUNT:
> -		return rpc_setup_pipedir_sb(sb, clnt);
> +		err =3D rpc_setup_pipedir_sb(sb, clnt);
> +		if (!err)
> +			clnt->pipefs_sb =3D sb;
> +		return err;
>  	case RPC_PIPEFS_UMOUNT:
>  		__rpc_clnt_remove_pipedir(clnt);
> +		clnt->pipefs_sb =3D NULL;
>  		break;
>  	default:
>  		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);

Looks right.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
