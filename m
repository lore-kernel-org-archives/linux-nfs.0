Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B7C6493643;
	Thu, 10 Sep 2026 15:47:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789055275; cv=none; b=m4NWC2oVmVG/0mPve4+jy5h4J3uflfRG+LDMc85rwKQoTRc3/I8/NgTJNEWxbp5LRuCOkOWHJasfnMz/iVXvUTOL3BcFgN7oicry1o9bgWGg182soukLDjlXYLg8P+urMjMZPN1ZqyuP0ENhokJqgPXm/Xhi9E8RXn54+X8li5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789055275; c=relaxed/simple;
	bh=TOy7SBm/fegV4EjRORkQ0GXT9NCChYqEFIBs+C2vk1g=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VcmVdnmNH4QcW/TTNnukZ2cdCG4pX03zFIDzGqvgX7Knl8rGBfdZpUKLKLU2Hh52LWt+GR3LxJ1HvuWxVjF4JeShy5dXJsC7tqy6juS0y3thISpxwKfiNqqKYVbt5FBKZaEyygWYFvmly3eNtiVYcxUE87MzCahMBpCwlSB9Chk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IFPNhcOV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IFPNhcOV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F5861F000FF;
	Thu, 10 Sep 2026 15:47:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789055273;
	bh=cgIP0eykI6dWly7Eh5U3U35ajrz0x3t8mRSUn9cHag0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=IFPNhcOVA6LQue/UQpT13Z8nNqIVS9UTvGfGvmYu/WylQswmD7eq5WFA4YQgsJryT
	 8Smf+uMTdvLdY2J2hZmvXzVv6Mu+S83vQ0kuOQfcUyCm1yg4OeXaP091maTZoBEeHW
	 K8UREgl6I1nHT9v5tYG34GKIArJ5rTQAjLNrWfalNoOzPtzzoyxdB+lG5zyx4CGjWk
	 2GrgwcpEnNmiKNn/t/6QQwN4YaCB5ejDRD7ZeiXO6jsNKwA/n4NkBlfNmLLQQhxYIW
	 I9c2pfHeUS4P5O1vJEi8dcigW/Vy3riu88VlgJFrrolk4YzO+bDSdma+3ngonFgGoI
	 C2wVXVPri6oxg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CA217F40066;
	Thu, 10 Sep 2026 11:47:52 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 11:47:52 -0400
X-ME-Sender: <xms:KNGiaq0jN0s5x8O7SDUJ981ONIuT0KYH74iC20dsHm5KK7BH8eqNOA>
    <xme:KNGian5yklVj6KmFMw9wFFSWclgcgeWChmc5DoK56rqk00PONixxEk-PHM6UjTYr_
    zG4GH2XM7Z1hIGd50WLAcvJw_zP4P9N1CLfy3QhtLebocg1-ahI8f1_>
X-ME-Proxy-Cause: dmFkZTGLvw3BleNJxEKuZlwh5rnA9tSzk4DbRhIdVQ7IpZvqY4oqAW0CpC6J75T3eJHFWf
    7W6saxzq1yy94XM2kHBdQpeomKZ2mah6nM/7J3WQwUX8O2bRvFDNYkrD47uKXmgE3pq/UP
    Wrc9P9gxf2k8XmOHNXfaZQGgEjqSC4nqM/2JSPHUVLXN52v41mqPzolKbr3RzFxhyIE46F
    YrXcmbJJR+lA+qrP0ZsBA5dz3WnnZ9I+M4fJ79BfKIemM6EKBXRTTvr45mB8ANLOG1F6HN
    +kPWMoOvAsjRoXoPul7Z9X6kgHCNqhH/G+7OlQVgN7AtEtWvB9HLVtJGneiI58dN63Y/gA
    dlsfYfH/opZLVE/falcnVW7dA7ka9fkzH8XJ7K/Q5oRIE3sIHvcpmkrpGM/g069bbR/Dc3
    Iw2PfFEH0kaczBr+ZCCCOHPMKzs1lFuSG3gh7bWylYjgja2eRqfPMYRKGJWTGBsoD5Lpok
    MRAbcWIy62XnEbjja2YpsMgL3rqcnGzCNYGOUK/6J/+46sLz7v015R6Xi0mp4WmxVi7jup
    DQE6ngtWoCW+YNMUXzpzfEY3QkBeyTCRGKJSFOFtg+HvCBQZWkxrMu23zl4/YTdObbIOP4
    gwzRvGBLP/FWitrtv/4kXkaA2KyBmI70CPLQbFiwh+yEbBQ7SrhiT54DXNhg
X-ME-Proxy: <xmx:KNGiavPi-ELwRADVCPrjxfzvXhjVWTNOyLieLogsFFkCqfbNlFod6g>
    <xmx:KNGiaqphkqDxhMyQ1LKRnvISV1Wg46m47hC4TaWHn2QtdElRbYzptg>
    <xmx:KNGiasclf55qc4gEHVvqpW1cNnqosSA9GoozCPszi31tGrWTOCYm5w>
    <xmx:KNGiaoQ_1W9OkE46XuS9GI_RQENKrdHMLT52f2txbRsapULmUHLY4w>
    <xmx:KNGiatb-Zq5Hv8aTvVBWxG3AGtdTIEpbCp6vEhquqIloR3X_LKk49HlY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id AD7D57811F3; Thu, 10 Sep 2026 11:47:52 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AHW2aQSR1Px3
Date: Thu, 10 Sep 2026 11:47:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <f64c2391-2810-406c-8c31-7f80cdde0832@slotpi15m67>
In-Reply-To: <20260910002934.192979-8-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-8-neilb@ownmail.net>
Subject: Re: [PATCH 7/7] nfsd: use vfs_lookup_open() for non-creating open requests
 too.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 10 Sep 2026, NeilBrown wrote:

> nfsd: use vfs_lookup_open() for non-creating open requests too.
>
> Now that we have vfs_lookup_open() for open requests which create, we
> can use it for non-creating requests too as vfs_lookup_open() is already
> able to do that.  nfsd4_create_file() is renamed to nfsd4_open_file()
> and enhanced to not always create, and is then used for all OPEN
> requests.
>
> The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
> moved into nfsd4_open_file() so it is closer to fh_full_post_attrs and
> fh_fill_post_noop calls.

fh_full_post_attrs is fh_fill_post_attrs().


> As ->op_create_mode isn't defined when op_create is zero, we need a
> local create_mode which is -1 (illegal value) when op_create is zero.

The field is ->op_createmode and the local is createmode.


> The non-create path now doesn't use nfsd_lookup().  As mount-point
> crossing including nfsd_check_access() is already included for existing
> names, this does not lose us anything.

The function is check_nfsd_access(), reached through nfsd_cross_mnt().

Is "already included for existing names" accurate? The only mount-point
crossing left in nfsd4_open_file() is the try_lookup_noperm() block,
and that consults only the dcache. More on that below.


> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/nfsd/nfs4proc.c | 109 ++++++++++++++++++++++++++---------------------------
>  1 file changed, 53 insertions(+), 56 deletions(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a6ba7618a307..1f3096486565 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -251,29 +251,30 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
>  }
>
>  /*
> - * Implement NFSv4's unchecked, guarded, and exclusive create
> - * semantics for regular files. Open state for this new file is
> - * subsequently fabricated in nfsd4_process_open2().
> - *
> + * Implement NFSv4's open semantics for regular files.
> + * Both create (unchecked, guarded, and exclusive) and non-create.
> + * Open state for this new file is subsequently fabricated in
> + * nfsd4_process_open2().
>   * Upon return, caller must release @fhp and @resfhp.
>   */

"Both create ... and non-create." is a fragment, and "this new file" no
longer fits when the file may already exist. Perhaps:

 * Implement NFSv4 OPEN semantics for regular files, both non-creating
 * and creating (unchecked, guarded, and exclusive). Open state for the
 * file is subsequently fabricated in nfsd4_process_open2().
 *
 * Upon return, caller must release @fhp and @resfhp.


> @@ -285,6 +286,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (status != nfs_ok)
>  		return status;
>
> +	status = fh_fill_pre_attrs_unlocked(fhp);
> +	if (status)
> +		return status;
> +
>  	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
>  		/*
>  		 * If name is already in dcache we need to check for mountpoints

First, the test reads open->op_createmode, which the commit message says
is undefined when op_create is zero. It works because
nfsd4_decode_open() zeroes the whole struct, so a non-creating OPEN
sees NFS4_CREATE_UNCHECKED here. Could the op_create test that sets
createmode be hoisted above this block, and the condition become

	if (!open->op_create || createmode == NFS4_CREATE_UNCHECKED) {

so the non-create path does not depend on that zero?

Second, nfsd_lookup_dentry() did a real lookup and then called
nfsd_cross_mnt() whenever nfsd_mountpoint() was true. try_lookup_noperm()
returns NULL when the name is not cached. In that case vfs_lookup_open()
opens whatever it finds on the parent's mount and fh_compose() uses the
parent's export.

For a referral junction (a regular file carrying the junction xattr),
nfsd_cross_mnt() would have swapped in the referral export. On a cold
dcache the client instead gets an ordinary filehandle for the junction
file, and a second OPEN of the same name, now cached, takes the
crossing path. The same applies to a bind-mounted file whose mount
target has its own export.

The Linux client sends OPEN by name without a preceding LOOKUP, so the
first access after a server reboot reaches this. Could the block do a
real lookup of the name, as nfsd_lookup_dentry() does, before deciding
whether to cross?


> @@ -373,11 +382,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		iap->ia_atime.tv_nsec = 0;
>  	}
>
> -	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> -	if (create_status)
> -		/* Might still succeed if no create is needed */
> -		oflags &= ~O_CREAT;
> -
> +	if (oflags & O_CREAT) {

Nit: O_CREAT is set only from open->op_create a few lines up. Would
testing open->op_create here read more directly?


> +		create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> +		if (create_status)
> +			oflags &= ~O_CREAT;
> +	}
>  	dget(parent.dentry);
>  	open->op_filp = vfs_lookup_open(&parent,
>  					&QSTR_LEN(open->op_fname,

This changes when a delegation is recalled relative to the access
check. oflags carries O_WRONLY or O_RDWR from op_share_access, and
vfs_lookup_open() opens the child with those flags. do_dentry_open()
does no permission check of its own and calls break_lease() on the
inode, so a conflicting delegation held by another client is recalled
here. Only afterwards does do_open_lookup() call do_open_permission()
and return NFS4ERR_ACCESS.

Before this patch a non-creating OPEN went through nfsd_lookup() and
do_open_permission() first, and the open that breaks the lease
happened later in nfsd_file_do_acquire(), where fh_verify() precedes
nfsd_open_break_lease(). So a client that can search the directory
but has no write permission on the file can now recall other clients'
write delegations on it by sending OPEN with SHARE_ACCESS_WRITE.

The create path has had this ordering since nfsd4_create_file() started
opening the file itself, but it was limited to opens that pass
NFSD_MAY_CREATE on the directory. Extending it to every OPEN makes it
reachable from any client with lookup access.

Could the access check move ahead of the open for the non-creating
case, or could the open be done O_RDONLY for the type check and the
share-access open deferred to the filecache as before?


> @@ -387,7 +396,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	if (IS_ERR(open->op_filp)) {
>  		status = nfserrno(PTR_ERR(open->op_filp));
>  		if (status == nfserr_wrong_type) {
> -			if (nfsd4_create_is_exclusive(open->op_createmode))
> +			if (nfsd4_create_is_exclusive(createmode))
>  				status = nfserr_exist;
>  			else
>  				status = nfsd_check_obj_isreg(parent.dentry);

On a re-export this arm changes the status a non-creating OPEN of a
directory returns. nfsd_check_obj_isreg(NULL) returns
nfserr_wrong_type, where nfsd_lookup() used to return nfserr_isdir.

The Linux client has no mapping for NFS4ERR_WRONG_TYPE, so
nfs4_map_errors() turns it into EIO. A "cat" of a re-exported directory
that is not yet in the server's dcache now fails with EIO instead of
EISDIR. NFSv4.0 clients are covered by the nfserr_symlink conversion in
do_open_lookup() and recover through a LOOKUP; v4.1 and later see the
change. Ceph splices before returning -EFTYPE, so it is not affected,
but nfs, gfs2 and smb all return -EFTYPE before instantiating anything.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
