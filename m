Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793098128;
	b=YUVJVU0z6V7rzCelXckJffrS2brEcUp8SVCcYnyU/PhxXeg0V0rZ09jFrGwQ5m0Nybln
	 eEFIy6ghA4sVTASE/w9u3yNFqSmjaWxO6B/DG4sA9mNMMIsAGbJpylhvee+hmzwdxoEjK
	 MsUY6PL1wIuqWDivrVUMbdgIV5+IiLV2Q3O3osFrkoxkY/NBvdWVZ01PTtYRrrj6Ka6Hf
	 viWtGearLvkNz0Q5ZjyTnMyXvRbD0jl8nsDarW19F9W1Bv6KMoTuDY1XjsP9qJ6VIXWGm
	 RFpwSGOKmSYQGPflsmOUzKa9S7nlIdQwDFLpma9Zuviz3hNZVcUDK6HPp4V7X9eJ2nA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793098128;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=7CWWHOzbA1986nWiuqWgV2mVX5RDvtKqBqkLDdjCvhI=;
	b=BObyPf30qBlj+/2oxEPpXRB/ESjgDfA87nPw0+69+FTDTxiRCzYlHncCMx6oqjJQNkZK
	 GIj0ymYn3Dq8gwW5C+m7RhbbzY5QXanY84s2IwVbOJwAC1tJfCfkim6apal7Z1hGVtGW/
	 v1xeYV8TqhFRzwZYc3dHanL5UiuLSBGbzH4gdc7q84eXf/Re7MhDD7lN1Q7HckeyBCLYJ
	 xgNaH/8x9p4ZS5iHEz5HzrosxtlE6/Wdu+zDo8DrcqMdrPUSj0otkjjuTnq6eaecnDnhA
	 7+AFeWs5hGJen9mwbOvvIW8Y4xOszQdWME8PZAgIyDDux9lnak8rhypOITruGyMi2Aw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lto6AK+n;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 583D8606A31D;
	Tue, 27 Oct 2026 10:48:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lto6AK+n
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 175B31F01825;
	Tue, 27 Oct 2026 10:48:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793098127;
	bh=7CWWHOzbA1986nWiuqWgV2mVX5RDvtKqBqkLDdjCvhI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lto6AK+nV9CsKY1nUB6t4Fv96PFOcPL/m/T/DqwWJGThiTczNjmMVIn/6m+275EIW
	 kNtf7+V3xIrjso+iCDX1vJYzR6p4iS2VANekqyQNnkWUKBCVzqWwRHVocRV8Od8UQD
	 oBNtKA7qfXcwFW/s212umuguFIR5lyC0F567jK3s13pIouxZNRoEUHjEvcUf9sOVEn
	 H4re7fIXsZYi+EFTKJoInGqxzXFFsyRGVxonIFGaR3zVO98mujLmK020KYMTj30wlf
	 n1o54goJ2Xa/uCvllRgUXM4uh2lwf29Olk4FioBWZvtugyMhId1D6FGd6Xwh9RKtv6
	 sqhln7m5zK+uA==
Message-ID: <64af740ee0e8a22c8cbc7abb32c7f659bed3faa0.camel@kernel.org>
Subject: Re: [PATCH] nfsd: shut down running servers in nfsd_net_exit()
From: Jeff Layton <jlayton@kernel.org>
To: Shuangpeng Bai <shuangpeng.kernel@gmail.com>, Chuck Lever
 <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org, 	linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
Date: Tue, 27 Oct 2026 06:48:44 -0400
In-Reply-To: <20261026235626.649844-1-shuangpeng.kernel@gmail.com>
References: <20261026235626.649844-1-shuangpeng.kernel@gmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Mon, 2026-10-26 at 19:56 -0400, Shuangpeng Bai wrote:
> Since commit 924f4fb003ba ("NFSD: convert write_threads to netlink
> command") the server can be started over netlink without mounting the
> nfsd filesystem. But that mount was the only thing pinning the module
> while threads run (commit f49169c97fce ("NFSD: Remove
> svc_serv_ops::svo_module") removed the per-thread reference), and
> nfsd_umount() is the only caller of nfsd_shutdown_threads().
>=20
> So when the server has been started via netlink, a plain "rmmod nfsd"
> succeeds while the threads are still running. exit_nfsd() then frees
> struct nfsd_net in unregister_pernet_subsys(), destroys the DRC slab
> and finally unmaps the module text underneath the running threads:
>=20
>   BUG: KASAN: slab-use-after-free in nfsd_file_net_dispose (fs/nfsd/filec=
ache.c:483) nfsd
>   Read of size 8 at addr ffff888109fe92d0 by task nfsd/300
>   Call Trace:
>    nfsd_file_net_dispose (fs/nfsd/filecache.c:483) nfsd
>    nfsd (fs/nfsd/nfssvc.c:957) nfsd
>    kthread (kernel/kthread.c:436)
>    ret_from_fork (arch/x86/kernel/process.c:158)
>   Freed by task 311:
>    kfree (mm/slub.c:6802)
>    ops_undo_list (net/core/net_namespace.c:257)
>    unregister_pernet_operations (net/core/net_namespace.c:1412)
>    unregister_pernet_subsys (net/core/net_namespace.c:1459)
>    cleanup_module nfsd
>    __se_sys_delete_module (kernel/module/main.c:804)
>=20
> followed by a general protection fault in nfsd_cache_lookup() as soon
> as a thread allocates from the destroyed drc_slab.
>=20
> Shut down a server that is still running for a net namespace in
> nfsd_net_exit(), which is invoked for every net namespace when the
> module is unloaded. nfsd_shutdown_threads() is a no-op when no server
> exists, so nothing changes for the common case. As the laundromat
> work is queued on laundry_wq until the server is shut down, destroy
> that workqueue after unregister_pernet_subsys().
>=20
> To reproduce: start the server with nfsdctl (or any other netlink
> client) without mounting the nfsd filesystem, then run "rmmod nfsd".
>=20
> Fixes: 924f4fb003ba ("NFSD: convert write_threads to netlink command")
> Cc: stable@vger.kernel.org # v6.10+
> Signed-off-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
> ---
> Tested on top of 7.3-rc7 with KASAN and with PROVE_LOCKING: with the
> server started over netlink and an NFSv3 request in flight, "rmmod nfsd"
> now waits for the request to complete and unloads cleanly; starting and
> stopping the server via netlink and via the nfsd filesystem still works.
>=20
> An alternative would be to take a module reference while a server
> exists so that rmmod fails with EBUSY, as it does while the nfsd
> filesystem is mounted. Stopping the server in nfsd_net_exit() seemed
> simpler and mirrors what nfsd_umount() does, but I am happy to rework
> it if the other behaviour is preferred.
>  fs/nfsd/nfsctl.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f32311f2d7cf..0a9679114b58 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -3113,6 +3113,7 @@ static __net_exit void nfsd_net_exit(struct net *ne=
t)
>  {
>  	struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> =20
> +	nfsd_shutdown_threads(net);
>  	kfree_sensitive(nn->fh_key);
>  	nfsd_net_cb_shutdown(nn);
>  	nfsd_proc_stat_shutdown(net);
> @@ -3200,9 +3201,9 @@ static void __exit exit_nfsd(void)
>  	remove_proc_entry("fs/nfs", NULL);
>  	genl_unregister_family(&nfsd_nl_family);
>  	unregister_filesystem(&nfsd_fs_type);
> -	nfsd4_destroy_laundry_wq();
>  	unregister_cld_notifier();
>  	unregister_pernet_subsys(&nfsd_net_ops);
> +	nfsd4_destroy_laundry_wq();
>  	nfsd_drc_slab_free();
>  	nfsd_lockd_shutdown();
>  	nfsd4_exit_pnfs();


I think I'm OK with either behavior (shutting down threads on rmmod or
taking a reference), but sashiko has some comments on this patch that
should be addressed:

https://sashiko.dev/#/patchset/20261026235626.649844-1-shuangpeng.kernel%40=
gmail.com

--=20
Jeff Layton <jlayton@kernel.org>
