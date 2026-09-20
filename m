Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96775470425;
	Sun, 20 Sep 2026 17:10:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789924256; cv=none; b=fFKnB1sbdMeNBzpRO/xb8mEehsvWEOt7EWQCryz+yncFPv6/I0nZ7oHid9L/YBUb3F4TLpOQ5yTOiwI3dKpwMinV5R7sxbLHIYKY477bcI43AeMLBpfhmmfZ09W24Mn2YRehf6h0TsHTe0z530W53d5EA6Y3wuOvupSWrMs50fg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789924256; c=relaxed/simple;
	bh=Y29JXEURD2D3mKWV7ZPfqPKBKaIrU2IfXdctaeUXKM8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=aN5O6d12Dh5BqvAemeJi9/B2SLhEd0rRjZ+KbfPFayAZw/0D5YEMXMromnj2KqwzOCB5517rKzkTOpRAIAoaa2PV2VXK0s41GslK79zsSwZmwBCVuFtldwFj4jMjAw4zJplQTJjGrS45D+8T6TxWb+Tdnc5IqIC0G2dFuY5omtg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SShZQv9s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SShZQv9s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 776921F00893;
	Sun, 20 Sep 2026 17:10:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789924254;
	bh=i+dCtK3mATKC0phxgL+FGZ7NvIG20FR7yV+DqyibTXE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SShZQv9sxooiYqURb7HF7NIjuhJADwV+Eq6MbRF5B4eC8CH2WoBZQ8Lf7Kh6Iel5L
	 NlXth7ylGYY4NQVZihTg5/mOCBv4+fkfpycNIlkct+PWGwj8i+Ux6s0XV98bBQBJ39
	 58yIfDjeOkVz1HEroNn1Aohj5/db/ANabwR1diMq4BvrzBs+eiaNOu1+76KdT7Zfw8
	 Y5e44ZJAf0iH0reD0r6dYZzgtD3wk++FyI0qkyXhxu0oEhKG1zbwUrGIMS6gXasDhJ
	 ln4l75oKgIAYQ15OvJwLdiYuhAz+ewuX4453MZtbCwsgGt3SCvcdAHW6Ys8IQK9ZzW
	 +TDpe/jZ4s6vA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AD7E3F40068;
	Sun, 20 Sep 2026 13:10:52 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:10:52 -0400
X-ME-Sender: <xms:nBOwai-WCyrKdgm-oqMMGRq--v0_sKHOZpcBrTBw06FIbhnSf-v-Xw>
    <xme:nBOwatj_v2DWvgNEH4NBc2droNcUB9KhXI24TcoUIgfIbopRrYMN8IfmNGlFGCcwD
    SwRF5l0O0A08_LiHjsRzD8Di4v6KQ6d_CxptIOpMh_iwgOHzMmqgWE>
X-ME-Proxy-Cause: dmFkZTFq6BOTrxtbKAYFC3eu6Csxip1s8l1OMiGhU17HqGpkjnGTFrsTwkP8CWDC0bLFyd
    Xbwm8Brc1dJ3bU1fw6NiiPAanLngjNjSA+NRMmzsHh4CaKgeEtYN/ZGt5vsNb9lj5jotmF
    FDVSGSeoQhSxt+JrJ+90pb6uWpi8HQEsmt8ZPqsY4u53RCBwDx16HilRKHMiEHODfes4i2
    oDiPYIzRBycYouTECA+DPXY3MlFIOwVpQWtU/WRZyTNG7fZkwcoJfkv6jFnsB+dvUdmnwx
    AxRTPQL3aQ0cac2+YrszVmP6CbV3XfBQFMCmnCFGaw/SyiAOLozD2Q1TBjHTFvnSHDW4PA
    Wulz422C3lNsdY/VN8srqJBHpbDsPdw6OMwnvkcKseaqxd1CBVFbybVNsoISOHzrU+yLHu
    4ZlH5vp+zaaPXn+Qz4uHVh/oKsy0JByZ4YhaMhXDO4Aqx7IaG+eWb+bvxcImn22kG1Bhv+
    mjGBEAJMmo+Qn8UMzl/mKybM55eK3PMQMa5l33EG9gvWjWBF9JAFtyAgAUpyv+gcgKjYyc
    5Lm2Duifg2JKYVRHGsCG6bd3m8eo9/P+RnCmreKptQgFQRG+OCv33AQVfnjkDunZ4/U5BK
    We2Vi/zLKSJyL15jPvTv+G0FCLBFBm6zKgjr9q5OI8Wah8/BN7H1aquYrn0g
X-ME-Proxy: <xmx:nBOwajjpxuydrp3kceGByBuO008VfwAlnO9NyLNv3Hnb-00eTDw03Q>
    <xmx:nBOwahVOq7NhfRjywTfePgjv_TWtus0w4b0BrNlRwH_2JZskYy7coA>
    <xmx:nBOwanshojTkoxnIWGIT3RWcZ61uX_LkBXwj36EgQZ0X-NzAdfJy3A>
    <xmx:nBOwai9rPEWvf2TBdIMH2KAtSKtA0C6r147WnhXyC6DPkBRG1M0heQ>
    <xmx:nBOwant6f5puO0EOwUkARh01SMkq8wsBxEE3MImM1FlKv6de-oyhhIcf>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 87906780070; Sun, 20 Sep 2026 13:10:52 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AhDSTzm6TOyk
Date: Sun, 20 Sep 2026 13:10:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <0b2597f9-2af1-448d-9bff-c9a96a07068b@slotpi15m67>
In-Reply-To: <20260919022441.3305170-13-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
 <20260919022441.3305170-13-neilb@ownmail.net>
Subject: Re: [PATCH v2 12/14] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, Sep 19, 2026, NeilBrown wrote:
> The functionality that was recently gathered into do_lookup_open() is
> now available from the vfs as vfs_lookup_open().  So nfsd4_create_file()
> can call that, with a few adjustments.
>
> This implementation shares more code with syscall open paths and so uses
> some filesystem interfaces slightly more correctly. Specifically:
>  - it doesn't call ->lookup before ->atomic_open is called
>  - it does pass LOOKUP_OPEN to ->d_revalidate
>  - only gets exclusive lock on parent if name is NOT in dcache

Thanks for listing these. Is the third item accurate, though?
vfs_lookup_open() calls lookup_open() with no lookup_fast() step ahead of
it, and lookup_open() picks the lock from O_CREAT alone, before it
consults the dcache:

fs/namei.c:lookup_open() {
    ...
	if (open_flag & O_CREAT)
		inode_lock(dir_inode);
	else
		inode_lock_shared(dir_inode);
    ...
	dentry = d_lookup(dir, &nd->last);
    ...
}

AFAICT the parent is locked shared only when nfsd4_create_file() has
already cleared O_CREAT because the NFSD_MAY_CREATE fh_verify()
failed.


> These are minor.  The main benefit is code-sharing. In particular
> it takes responsibility for locking out of nfsd so that planned changes
> can happen entirely in VFS code.
>
> We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from
> break_lease of try_break_deleg() get passed back.

"that that" is still here from v1. Also, s/break_lease of/break_lease() or/


> We need to mask any type out of "mode" else vfs_lookup_open() will warn.
>
> Signed-off-by: NeilBrown <neil@brown.name>

[ ... ]

> @@ -412,11 +366,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		/* Might still succeed if no create is needed */
>  		oflags &= ~O_CREAT;
>
> -	open->op_filp = do_lookup_open(&parent,
> -				       &QSTR_LEN(open->op_fname,
> -						 open->op_fnamelen),
> -				       oflags,
> -				       open->op_iattr.ia_mode);
> +	open->op_filp = vfs_lookup_open(&parent,
> +					&QSTR_LEN(open->op_fname,
> +						  open->op_fnamelen),
> +					oflags,
> +					open->op_iattr.ia_mode & S_IALLUGO);

Can this fail an OPEN that nfsd_permission() would have allowed?

With 09/14 applied, an existing file that ->atomic_open did not open goes
through vfs_lookup_open()->do_open()->may_open(), which does:

	error = inode_permission(idmap, inode, MAY_OPEN | acc_mode);

do_open() zeroes acc_mode only when FMODE_CREATED is set. The removed
do_lookup_open() used dentry_open() for a positive dentry, which makes no
permission check, the same as __nfsd_open(). The permission decision was
left to do_open_lookup()->do_open_permission()->nfsd_permission(), which
runs after nfsd4_create_file() returns. Now may_open() fails first, and
the two relaxations in nfsd_permission() are never consulted.

The case I am most concerned about is a replayed exclusive create. An
NFSv4.0 EXCLUSIVE4 OPEN carries no attributes, so:

fs/nfsd/nfs4proc.c:nfsd4_create_file() {
    ...
	if (!(iap->ia_valid & ATTR_MODE))
		iap->ia_mode = 0;
    ...
}

and the file is created with mode 0000 until the client's SETATTR
arrives. If the client resends the OPEN in that window (after a server
restart, say), the dentry is positive and FMODE_CREATED is clear, so
may_open() returns -EACCES for a non-root owner. The verifier comparison
further down:

	if (!open->op_created &&
	    nfsd4_create_is_exclusive(open->op_createmode) &&
	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
	    inode_get_atime_sec(d_inode(child)) == v_atime &&
	    d_inode(child)->i_size == 0)
		open->op_created = true;

is never reached, so do_open_lookup() never gets to add
NFSD_MAY_OWNER_OVERRIDE, and the retry gets NFS4ERR_ACCESS where it
used to succeed.

The other relaxation is NFSD_MAY_READ_IF_EXEC, which do_open_permission()
always sets. An UNCHECKED create for read that finds an existing mode
0111 file now fails in may_open() with -EACCES. That is rare for a
creating OPEN, but would 14/14 not make it the common case, since a
client reading an execute-only binary sends a non-creating OPEN?

Also, vfs_lookup_open() calls do_open() only when FMODE_OPENED is clear.
Does that mean the result differs by exported filesystem? ext4, xfs,
btrfs and tmpfs have no ->atomic_open and get the new may_open() check,
while a re-exported NFS or a fuse export skips it.

Would it work to let this caller reach do_open() with an acc_mode of
zero, so that nfsd_permission() stays the only authority for NFS
requests? If the new check is wanted on the nfsd side, the patch
description needs to say so and explain how the exclusive replay case
is handled.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
