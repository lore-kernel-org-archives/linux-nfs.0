Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4AF0456DF6
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 17:02:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786986151; cv=none; b=V4RN3E72HmwayGef4G3Gv1F8fB7ZKW3hIi+ewlZ4PUNnsI6k7ehvSMSVU+3ibZpjMVxlHbG3/kYTsDV+PVHevRS8xDMW5mLo2D+eebjpYKq7jBLSOnTY5fOAuOAhc695bUnBicVPm7VWmcDRCJpP6bc49U7osvekwS323P+HzQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786986151; c=relaxed/simple;
	bh=NnCqr6T3SuGzDXRZnRIzxDDgPl8qUa6I9my00DpugnE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=oAgY1L95bU7gdbF9DzkX1LiGBHAG9Me7ULDTv2iFpYRDpPA9S0rLqgcENAEFzZPk/Q0f/zkBiwg+W5KFI5IvHvfm589hN9kg97FqnxkiPHe6S1fKAj/2+zxFRM7Ul30iWIq9iHYnU8Tbjhmc0nQpCHVHJupQ2YRvkl0BsliO7GU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FMW6QHCg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FMW6QHCg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9788B1F000E9;
	Mon, 17 Aug 2026 17:02:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786986147;
	bh=OBLh0HLS4f0dIqSiOTYd2uMk3x/SVsnze/HKqCylJHo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FMW6QHCgemZtZpImM7/FvJA33pMoXyhiooflt14bpfGFdx6t/db/WLIufFURy8943
	 XhtGEm0m6Kpr0wWedxCVFIrhKntSTQLxX27CYKUAv01mLwJSvXyWPkqaRnQtgQm5SU
	 2s4rXRJWK9dqhfbGp9WSwzn0Nri6DtFAReaUknrEVJRFqx+aybvpCiC15iaLNSdYdK
	 dJIxhtE9GCbk0IvKVhWXnodLQmw2QI7ub7KNJ8Hk0ZTXSVPFUucln+aiBl89UsbZym
	 7V6ETkUX//VC80Eu+vt8GvphaiIvNefa+1h9a00J/Axc0DcudGg0OcjawqZd+Brozj
	 QZDUoBAg9D84g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C166BF40068;
	Mon, 17 Aug 2026 13:02:26 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 17 Aug 2026 13:02:26 -0400
X-ME-Sender: <xms:oj6Daq3lNlAa7_E-Cvc_rB8yHV0myDsYlQ7_cmRPRD2cGTRzHEOEhQ>
    <xme:oj6Dan4MxBZ4mgoRU4qKZWjKRguh5-grhgTr4qn2JrA7MnwqbxWnEnHvGw79WjayQ
    LpzL4bZsoSSBI-ABp7NXrLTOluxJRdR8rkGGl1aC9oQ0LXHYuvb4q4>
X-ME-Proxy-Cause: dmFkZTFwW/7LgTYCGmU/5AkB+Y2aIe6k+ugO+UL8CuKLQucozTvtVSG0qtHiVubQk21gq4
    Z76Nb5ttHR1EC+Sb7hmANLCS6ghD8DYytVFXyEo6eeGIMIazaZePOvLb3M6IsgffgT88+A
    sra//SaIv20zqSvnbpVZz19DRn3HRTX1sRpxx1cf8MoR6P/6VCaciGrngd7J+hIoh66pcB
    uN1DU9u9k8J5Hcuu9w4xbHEnqqizz7qDX135NZe/vLvC7nlep1DLPZ959MDlTohOA8btTs
    jE3TZitrLDXM4lj3feSx7Xvc5gsJui3Q80X4CVIDKwhqpm8FSTW53RvlizBJf/CjZYN1Qn
    Uay+iWymd7sISHmfoFntx5dAxDygo1tLgjIKZbkIuF2ER5hQemRfqnxri0zEn7Zb7IBued
    of1vGRSbfew25sfSxMxoQyKFPkUkFfRG73B/WxN0Y08kwC8CLVXcsTogKLTPooFoy9kJWT
    ogMLoPG6HcRRck8VhD38eMGQsH3GQpCb4+IikCcrH2FbxI5tyBrxJG7FBRMOIrbNA4h5dj
    J90/dEAn/9UwtScZqGfDOdQUxE0CiSUgeiN9TxgC7aSL/zWh7+HxGL3EeLO4k1Sfvu1/f6
    cmOuxDXBTEC1JqFqBtV6HbAruvrQ7LLmpFgqFdlOzB9dNl2GF6bkn+NmqKGQ
X-ME-Proxy: <xmx:oj6DaojdxD6NeMlYuYbvdhWZqttO2YZyObzC5Zho6_qNRp9QKTfA4w>
    <xmx:oj6DaqXyJ6Ypxe5tjUZYrDIKOntq8EhYKOXqpWp1CBcjyI0JTLWcmw>
    <xmx:oj6DanVdlM9f7S2K0IQa4kLlODpUbRqdhSkBgjp_vtK8XcIvZHSykg>
    <xmx:oj6DaqgHL9udekc3NDjAvoYewWiXUBveb2v5hmpkfGtkVJsofSWufQ>
    <xmx:oj6Daiapz2AJhsOvJNUo93EySay2Oes5sKtJKlWyChFuyPyT80qU1sra>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A0C337811F0; Mon, 17 Aug 2026 13:02:26 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ARMaRDIs-swB
Date: Mon, 17 Aug 2026 13:02:06 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Message-Id: <00464c46-a4e1-417e-8169-e3b73a6b0717@app.fastmail.com>
In-Reply-To: <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
References: <20260717093001.1972119-1-neilb@ownmail.net>
 <20260717093001.1972119-19-neilb@ownmail.net>
 <bb2eb0ef5172cbfc4452f7a8a2afc866f629557f.camel@kernel.org>
Subject: Re: [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating open requests
 too.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 1:12 PM, Jeff Layton wrote:
> On Fri, 2026-07-17 at 19:28 +1000, NeilBrown wrote:
>> From: NeilBrown <neil@brown.name>
>> 
>> Now that we have do_lookup_open() for creating open requests, we can use
>> it for non-creating too as do_lookup_open() is already able to do that.
>> 
>> This prepares for switching to vfs_lookup_open() once the VFS provides
>> that.  This will ensure consistent code and fs-interaction with VFS open().
>> 
>> The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
>> moved into nfsd4_open_file() (renamed from nfsd4_create_file()) so it is
>> closer to fh_full_post_attrs and fh_fill_post_noop calls.
>> 
>> As ->op_create_mode isn't defined when op_create is zero, we need a
>> local create_mode which is -1 (illegal value) when op_create is zero.
>> 
>> The non-create path now doesn't use nfsd_lookup().  As mount-point
>> crossing including nfsd_check_access() is already included for existing
>> names, this does not lose us anything.
>> 
>> We now only call mnt_want_write() is there is a flag which indicates we
>> might want write access - previously O_CREAT was always set.
>> 
>> Signed-off-by: NeilBrown <neil@brown.name>
>> ---
>>  fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++-----------------------
>>  1 file changed, 56 insertions(+), 57 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index b7fdc75c4b81..11d0411dec08 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct path *parent,
>>  	struct file *filp = NULL;
>>  	struct path path;
>>  	struct dentry *child;
>> -	int want_write_err = 0;
>> +	int want_write_err = -ENOENT;
>>  
>> -	want_write_err = mnt_want_write(parent->mnt);
>> +	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
>> +		want_write_err = mnt_want_write(parent->mnt);
>>  
>>  	child = start_creating(&nop_mnt_idmap, parent->dentry, name);
>>  	if (IS_ERR(child)) {
>> @@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct path *parent,
>>  }
>>  
>>  /*
>> - * Implement NFSv4's unchecked, guarded, and exclusive create
>> - * semantics for regular files. Open state for this new file is
>> - * subsequently fabricated in nfsd4_process_open2().
>> - *
>> + * Implement NFSv4's open semantics for regular files.
>> + * Both create (unchecked, guarded, and exclusive) and non-create.
>> + * Open state for this new file is subsequently fabricated in
>> + * nfsd4_process_open2().
>>   * Upon return, caller must release @fhp and @resfhp.
>>   */
>>  static __be32
>> -nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> -		  struct svc_fh *resfhp, struct nfsd4_open *open)
>> +nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> +		struct svc_fh *resfhp, struct nfsd4_open *open)
>>  {
>>  	struct iattr *iap = &open->op_iattr;
>>  	struct nfsd_attrs attrs = {
>>  		.na_iattr	= iap,
>>  		.na_seclabel	= &open->op_label,
>>  	};
>> -	int oflags = O_CREAT | O_LARGEFILE;
>> +	int oflags = O_LARGEFILE;
>>  	struct dentry *child = ERR_PTR(-EINVAL);
>>  	struct path parent = {
>>  		.mnt = fhp->fh_export->ex_path.mnt,
>>  		.dentry = fhp->fh_dentry,
>>  	};
>>  	__u32 v_mtime, v_atime;
>> -	__be32 status, create_status;
>> +	int createmode = -1;
>> +	__be32 status, create_status = 0;
>>  	int want_write_err;
>>  
>>  	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
>> @@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  	if (status != nfs_ok)
>>  		return status;
>>  
>> +	status = fh_fill_pre_attrs_unlocked(fhp);
>> +	if (status)
>> +		return status;
>> +
>>  	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
>>  		/*
>>  		 * If name is already in dcache we need to check for mountpoints
>> @@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  	if (!IS_POSIXACL(d_inode(parent.dentry)))
>>  		iap->ia_mode &= ~current_umask();
>>  
>> +	if (open->op_create) {
>> +		createmode = open->op_createmode;
>> +		oflags |= O_CREAT;
>> +	}
>>  	/*
>>  	 * For the EXCLUSIVE modes we do our own uniqueness tests
>>  	 * so don't want O_EXCL.
>>  	 */
>> -	if (open->op_createmode == NFS4_CREATE_GUARDED)
>> +	if (createmode == NFS4_CREATE_GUARDED)
>>  		oflags |= O_EXCL;
>>  
>>  	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
>> @@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  
>>  	v_mtime = 0;
>>  	v_atime = 0;
>> -	if (nfsd4_create_is_exclusive(open->op_createmode)) {
>> +	if (nfsd4_create_is_exclusive(createmode)) {
>>  		u32 *verifier = (u32 *)open->op_verf.data;
>>  
>>  		/*
>> @@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  		iap->ia_atime.tv_nsec = 0;
>>  	}
>>  
>> -	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
>> -	if (create_status)
>> -		/* Might still succeed if no create is needed */
>> -		oflags &= ~O_CREAT;
>> -
>> +	if (oflags & O_CREAT) {
>> +		create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
>> +		if (create_status)
>> +			oflags &= ~O_CREAT;
>> +	}
>>  	open->op_filp = do_lookup_open(&parent,
>>  				       &QSTR_LEN(open->op_fname,
>>  						 open->op_fnamelen),
>> @@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  		goto out;
>>  
>>  	if (!open->op_created &&
>> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
>> +	    nfsd4_create_is_exclusive(createmode) &&
>>  	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
>>  	    inode_get_atime_sec(d_inode(child)) == v_atime &&
>>  	    d_inode(child)->i_size == 0)
>>  		open->op_created = true;
>>  
>>  	if (!open->op_created) {
>> -		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
>> +		if (open->op_create == NFS4_OPEN_NOCREATE ||
>> +		    createmode == NFS4_CREATE_UNCHECKED) {
>>  			/* NFSv4 protocol requires change attributes
>>  			 * even though no change happened.
>>  			 */
>> @@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
>>  	fh_init(*resfh, NFS4_FHSIZE);
>>  	open->op_truncate = false;
>>  
>> -	status = fh_fill_pre_attrs_unlocked(current_fh);
>> -	if (status)
>> -		goto out;
>> -	if (open->op_create) {
>> -		/* FIXME: check session persistence and pnfs flags.
>> -		 * The nfsv4.1 spec requires the following semantics:
>> -		 *
>> -		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
>> -		 * Reply Cache  | server |                 |
>> -		 * -------------+--------+-----------------+--------------------
>> -		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> -		 *              |        |                 | (SHOULD)
>> -		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
>> -		 *              |        |                 | (SHOULD NOT)
>> -		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> -		 * yes          | no     | GUARDED4        | GUARDED4
>> -		 * yes          | yes    | GUARDED4        | GUARDED4
>> -		 */
>> +	/* FIXME: check session persistence and pnfs flags.
>> +	 * The nfsv4.1 spec requires the following semantics:
>> +	 *
>> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
>> +	 * Reply Cache  | server |                 |
>> +	 * -------------+--------+-----------------+--------------------
>> +	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> +	 *              |        |                 | (SHOULD)
>> +	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
>> +	 *              |        |                 | (SHOULD NOT)
>> +	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
>> +	 * yes          | no     | GUARDED4        | GUARDED4
>> +	 * yes          | yes    | GUARDED4        | GUARDED4
>> +	 */
>>  
>> -		current->fs->umask = open->op_umask;
>> -		status = nfsd4_create_file(rqstp, current_fh, *resfh, open);
>> -		current->fs->umask = 0;
>> +	current->fs->umask = open->op_umask;
>> +	status = nfsd4_open_file(rqstp, current_fh, *resfh, open);
>> +	current->fs->umask = 0;
>>  
>> -		/*
>> -		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
>> -		 * use the returned bitmask to indicate which attributes
>> -		 * we used to store the verifier:
>> -		 */
>> -		if (nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
>> -			open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
>> -						FATTR4_WORD1_TIME_MODIFY);
>> -	} else {
>> -		status = nfsd_lookup(rqstp, current_fh,
>> -				     open->op_fname, open->op_fnamelen, *resfh);
>> -		/*
>> -		 * NFSv4 protocol requires change attributes even though
>> -		 * no change happened.
>> -		 */
>> -		fh_fill_post_noop(current_fh);
>> -	}
>> +	/*
>> +	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
>> +	 * use the returned bitmask to indicate which attributes
>> +	 * we used to store the verifier:
>> +	 */
>> +	if (open->op_create &&
>> +	    nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
>> +		open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
>> +				      FATTR4_WORD1_TIME_MODIFY);
>>  	if (status)
>>  		goto out;
>>  	status = nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
>
> This patch is making the pynfs DELEG8 test fail. It seems like this
> patch breaks the behavior where the server sends back NFS4ERR_DELAY on
> an OPEN while waiting for a DELEGRETURN. The server just doesn't send a
> reply until the delegation times out with it.

Neil, I need a response from you. How soon do you intend to address this
issue? Can this patch be dropped safely from the series, or do I need to
drop the whole series?


-- 
Chuck Lever
