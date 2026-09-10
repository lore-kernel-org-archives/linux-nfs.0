Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D19DE4A5C45;
	Thu, 10 Sep 2026 15:41:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789054916; cv=none; b=Dsa2XCn+1dFBJGG0a4pJOiJpsFkRu8J/kdzI0Xh4kkvS9FD5VyZBPbpq/ZFJVVutuyU2Ogm3PWsoopQ5I3WBNCGait4BO14DLIwBdaNjug6Ja7SVKqYrRmcTd/w4CMKBa/fgpUuJy6XPFjJwYLfIIsArAqUP9z44ZIsCYFVjuHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789054916; c=relaxed/simple;
	bh=Cv83Y2cxQRifUNTWe9xbJvJO6VwFOAjdqwlHnX674oo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Ka6OJUoinIW0wqe0lBzUJeA6o5WyPz/d7YJ2EqlNmApY1Z4p7hC9CSYl0r6o9ggoG6p202nMHov4p3boDWQS0jE5PD7uLOEeO+WUCmFMO6S+rwj4TtyB5VqCy6vz2odi3LYEl5nhnqs9DbFSAa0ciZJKHMpL9mfvFaKSKjKnETY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sw35lEYj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sw35lEYj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 59E0B1F00898;
	Thu, 10 Sep 2026 15:41:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789054914;
	bh=0QcbBzUrFpfzDPq8LltXH9cRcxoNNQvpvYbHvP4XDKk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Sw35lEYj0dssbRfLXJ6497t9W0rPwS0N/We7qEMWfRhz41Zp1QuI8iOQ8a8WXvC+5
	 ljRMgn1Iuu/6wjkWWpL0BL2oXu3nMohReaPGx+/TGlffPDWrtfN+YHUR3C1ZkAMeb+
	 /FopKqu7UTxMWcMirvYqh7Dw2LSI1uTxs9bzU1PCQDrwrCHlIXKpxCoe3tWgzt7I0b
	 eOZ2qFXljWjMurnewKcg5ES0GUdOy54NoJpMx5tkwFhjfoIuelBHGAXNcusKAKmNUG
	 X6TV6ZIFnSOYO5vB8rgw4uqN9lkgGeHQIGpFkrwH0nOOrjI3AQ5c+K4l4t8Dc9jxpX
	 t1Om2FQesH+aw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 80DE9F40068;
	Thu, 10 Sep 2026 11:41:53 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 11:41:53 -0400
X-ME-Sender: <xms:wc-iapjM0lA8G7RPlIRdvKnuRVSDtZeDgOPvsqFVaJLP2jbt02cfUw>
    <xme:wc-iao2AQBVKvZpGIgG-X1AnuD4N5T6D5tEyFEXFYaUcBkIC6KWKALohrpoycXyfR
    yLcl8n3VPbUeebjgInV5pPcOsqxTfRkjhl4D2I2v6-3H8lekf0qETFM>
X-ME-Proxy-Cause: dmFkZTGFWIFasjoDmcN0ZdVfwPz1V2eKZ4EdNrvQlWrrdHijKpjhJt57pa0IDwthBJpBLP
    hp0rkARqFV0J8wXxnws3vIuNnizwSseM56cP+IHkMHHwJUeedx6ZpXg4LhE5DKw0nbrRiD
    FknH2tSI170eCdxRW232ZB4avKsd5r1TS4jlcee4PuEgE2P8sBpiR+U99D1ig6xfJVhtc0
    VPqeB33Rj55uDmKAlSgH9EAUmdu6uP4XXDx6yrI8M+MW2f2Nzfe3s2M7eBd0GeJAETKTgY
    V7RyH88sgBustPmcBYw5TLs4ZI0NIis3jz+22fAUVuXxcwoKQzICZ4yKIL3RllbEHIt2EY
    IvrRjm/mBwGW0HRQn/8lEWPPcy9dif7p2Crs3JSZpdmnFsSO7BY6LRo04PlaHR8FhrakIt
    nfNmzL32cfFiviLD1PmL2KhOdBNwny/z2UzQqmNv8CnQ3T+cbhJ+8lSE1sS7iYNYmB4U6e
    6+RpVU/SG2iIz8ZSSj/A464oaE3iVZRNj+ExAq+Yec/m6GIWBM3PowFnzEnzz7DusAEXEo
    TeVLTBOzV/fvpllYTEM5GveIktK3qN2wfGL/Iu7Uii+96Se1JDBQ4YCo/ArUrVS4RQ5TOJ
    QEkY6Fr6PqaDv6htxBculf+fwj4MofUotAY1+Q/m+mgNcfkmIH3qg/TirRkA
X-ME-Proxy: <xmx:wc-iamZxn_KCobl2g3AFfkB2-GALSdRRdVF90fjHRzKVBB-43V-GPw>
    <xmx:wc-iaqFafBodbpnbCLBORcsFcyMcHOFt4yuhBKQna5k_im5-dIpxEQ>
    <xmx:wc-iavIQgHLnveL6TrrwH32IvT7WU8nzV_0YkXXpfhylqfJ67SNFSw>
    <xmx:wc-iatMCJp0-IZSJhRuxNzgQPiT1iQ-f8yCvJy9HSP-9vDtrWCgPgw>
    <xmx:wc-iankhFxhfPv-B5q_RIJUe2QchJwmMW5R9Eoo1zZG29YWCEWVlRX0P>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5AFBD7811F0; Thu, 10 Sep 2026 11:41:53 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQ0ownMfFdNZ
Date: Thu, 10 Sep 2026 11:41:31 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <e36532d5-e37f-4d71-b83a-c8d19d87811f@slotpi15m67>
In-Reply-To: <20260910002934.192979-6-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-6-neilb@ownmail.net>
Subject: Re: [PATCH 5/7] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

>     This implementation shares more code with syscall open paths and so uses
>     some filesystem interfaces slightly more correctly.  It also takes the

Which interfaces? The concrete difference I can see is that lookup_open()
honors ->atomic_open, which do_lookup_open() never called. Naming that
would be clearer than "slightly more correctly".


>     We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from

Repeated word: "that that".


>     vfs_lookup_open() always returns -EFTYPE if a non-regular-file was
>     found, and provides the dentry in parent.dentry.  We can use
>     nfsd_check_obj_is_reg() to turn this into an error.
>
>     As parent.dentry could be NULL, we enhance nfsd_check_obj_is_reg() to
>     cope with that.

The function is nfsd_check_obj_isreg(), in both places.


>     vfs_lookup_open() will return -EEXIST if required for
>     NFS_CREATE_GUARDED4 as O_EXCL is passed in.  Other checks for
>     and existing object need only test for nfsd4_create_is_exclusive().

s/and existing/an existing/, and the identifier is NFS4_CREATE_GUARDED.

The -EEXIST claim holds only on the path through the tail of
vfs_lookup_open(), where the O_EXCL test runs before the d_is_reg()
test. When lookup_open() itself returns -EFTYPE, vfs_lookup_open()
returns before either test. See below.


> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3a82af381a8d..0fd5a6411ed3 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c

[ ... ]

> @@ -312,7 +269,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		.na_iattr	= iap,
>  		.na_seclabel	= &open->op_label,
>  	};
> -	int oflags = O_CREAT | O_LARGEFILE;
> +	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;

Nit: do_dentry_open() strips O_CREAT, O_EXCL and O_TRUNC from f_flags
and leaves O_NONBLOCK in place, so op_filp now carries O_NONBLOCK into
the filecache entry that nfsd_file_acquire_opened() builds from it.
Files opened through __nfsd_open() do not. Is that divergence
intended?


>  	struct dentry *child = ERR_PTR(-EINVAL);
>  	struct path parent = {
>  		.mnt = fhp->fh_export->ex_path.mnt,
> @@ -424,28 +381,29 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		/* Might still succeed if no create is needed */
>  		oflags &= ~O_CREAT;
>  
> -	open->op_filp = do_lookup_open(&parent,
> -				       &QSTR_LEN(open->op_fname,
> -						 open->op_fnamelen),
> -				       oflags,
> -				       open->op_iattr.ia_mode);
> +	dget(parent.dentry);
> +	open->op_filp = vfs_lookup_open(&parent,
> +					&QSTR_LEN(open->op_fname,
> +						  open->op_fnamelen),
> +					oflags,
> +					open->op_iattr.ia_mode & S_IALLUGO);

Nit: after this call "parent.dentry" is the child (or NULL), while a
few lines up IS_POSIXACL(d_inode(parent.dentry)) reads the same
expression as the parent directory. The VFS patch renamed its parameter
to @path for this reason. Would renaming the local here avoid the same
trap?


>  	if (IS_ERR(open->op_filp)) {
>  		int hosterr = PTR_ERR(open->op_filp);
>  
> -		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
> -			switch (hosterr) {
> -			case -EISDIR:
> -			case -ELOOP:
> -			case -EFTYPE:
> +		if (hosterr == -EFTYPE) {
> +			if (nfsd4_create_is_exclusive(open->op_createmode))
>  				hosterr = -EEXIST;
> -			}
> +			else
> +				hosterr = nfsd_check_obj_isreg(parent.dentry);
>  		}

Does this drop the NFS4ERR_EXIST mapping for GUARDED4?

The old test covered GUARDED as well as the two EXCLUSIVE modes.
nfsd4_create_is_exclusive() covers only EXCLUSIVE4 and EXCLUSIVE4_1, so
a GUARDED open that finds a non-regular object now takes the else arm
and returns NFS4ERR_ISDIR, NFS4ERR_WRONG_TYPE, and so on. RFC 8881
section 18.16.3 says a GUARDED4 duplicate is NFS4ERR_EXIST.

Keeping "open->op_createmode != NFS4_CREATE_UNCHECKED" here would
restore the old mapping without depending on the ordering of checks
inside each filesystem's ->atomic_open.

Separately, can this arm return nfs_ok? nfsd_check_obj_isreg() returns
0 for a regular file, and vfs_lookup_open() can leave a regular file in
parent.dentry when the d_lookup() it does after an -EFTYPE races with a
rename (the VFS marks that case with a WARN_ON_ONCE rather than
excluding it). nfserrno(0) is nfs_ok, op_filp is then set to NULL, and
nfsd4_create_file() returns success with resfhp never composed. It only
fails safely today because do_open_lookup() then calls
nfsd_check_obj_isreg() on the NULL fh_dentry. Something like

		if (!hosterr)
			hosterr = -EFTYPE;

would address that.


>  		status = nfserrno(hosterr);
>  		open->op_filp = NULL;
>  		if (status == nfserr_noent && create_status)
>  			status = create_status;
> +		dput(parent.dentry);
>  		goto out;
>  	}
> +	dput(parent.dentry);
>  
>  	child = open->op_filp->f_path.dentry;
>  	open->op_created = open->op_filp->f_mode & FMODE_CREATED;
> @@ -462,7 +420,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		open->op_created = true;
>  
>  	if (!open->op_created) {
> -		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
> +		if (nfsd4_create_is_exclusive(open->op_createmode)) {
> +			status = nfserr_exist;
> +		} else {

Same question here. GUARDED used to get nfserr_exist from this branch
and now gets the "no change happened" arm. It is unreachable for GUARDED
today only because vfs_lookup_open() returns -EEXIST whenever O_EXCL is
set and nothing was created. Should this also stay as
"!= NFS4_CREATE_UNCHECKED" so the protocol rule is enforced here rather
than relying on that ordering?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
