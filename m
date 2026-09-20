Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90E023CE0A4;
	Sun, 20 Sep 2026 17:13:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789924425; cv=none; b=FkpsjyCz6ggIQq8B/qJaXQOF/fOCUtfHJ3pmM5Y6rU2SGavxMGD8K/rOVineLcI+/4skWALC/WJtv1zptcSGSLEH69jypayLVKPeymIrfpG/HBLPgFHKbOhrctUTPjeEG0sarP7haEPcwLtuQ8aUj9U3HlJ5mpOvhDVcGvXdpwM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789924425; c=relaxed/simple;
	bh=aAbjlVFRet/0a+Hx3O7Dyh/dGQ2tNy800tKg9xdBi60=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rFttenD7a9HkptGng5D0hyekTljGdtWTmPJc0z1CgnbLI00ihJv4/LmBAZ8ylOk9RmnjoofYf5ba8uzcwMDxb/Y+jDMoIcz+31bMDQvyD/N8Gpk4/u4GZ8NY2bbiLuloRCKSLTuAYsZJ6WIG2XyWP2JknnD+vnDIMVAVyUGyPZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GawdX7yR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GawdX7yR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA8DD1F00898;
	Sun, 20 Sep 2026 17:13:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789924424;
	bh=s5+ypruUej3MvOqRrwRHaCrYLqaIsa2+ve3GjrhIfzo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GawdX7yRUS9G4soY/llhIEObDfa+31AFM4tRLkn9ecnjHJT/QV9jFfsfkMe3qJWTE
	 ax6ohx0Jwif/XrPG3nf8C3lXWdyFtjFfMSaYYgX0sJLTPLV2qesy+myPin4gT9uY90
	 Pw7Ik9/gnD+b2O95bYaxWIcp2Y1bvbCxAFRip/Xbz2ScZpeMu8GGvmL6baKEsQXXtp
	 7XK7l3j4L0SXOuXUx0dwySv+rTaZGIkyWpb3laKB5E/a7LCUf/Vs0pZEKBWO2rmnET
	 THzpStV2HxU3V5P2wGqcq4tlVG9za+kSGdijHbJqNIq+5wUh6j5kvTT9oMeiKD5rZ5
	 AGGaP+dSA/DTg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 091BCF40066;
	Sun, 20 Sep 2026 13:13:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:13:43 -0400
X-ME-Sender: <xms:RhSwamZCWCZsWF7KQ4U4iuI0PqBGqjM5VUaooEfBlDyrdJMJmeyeYQ>
    <xme:RhSwakO90iQ2DT4U5vlKPAf2Y5IlSHVPbkgWuq46iqQ92VKq2b9EhlaPafH5CsQEJ
    U0LJpPtDlXChHsx1OEKoNYzcsaEF2JqJ8atyBW7EKBigVMQPl1v6A>
X-ME-Proxy-Cause: dmFkZTFOrMtTVTmiSu+HJol2ch3sUDDTyPSzR66nZCAwMgPMsuuooTYoXbzPm2z4WXATkD
    m2G5DiZBB9u6DQHddY//e+woyllFEZasu9CMmZwRGT7h8iY0zuZ6fUOxCDufFGr1ZV7Sk7
    omX0HZPU+pQGIq7LtSVzVv+HM9t466FyaByuKhHKfJwJmjx+6Gm/9Ic+FqxyPNdMX8NS8P
    llcqB8tH9jJ8b2UA4FcQODkgXEpkcSmzVympD6rsGf4UpQdnC+hKRc5GqegehdcDarihbW
    TQDPX/iaBNK+TbRD8FpAK4XL+QRAPP6vGEydcZ9/CcJtABptTPKiE8UWeYCnw9TH6d3iVj
    70TSUjo/k8C/oKHWLYMQd6izf3Iu472cVhb/yNX+Q+h/Sybtp5F4Bw0rRx3g55f1P6PydW
    33j0bICEoLnPqAQqRh/pr9HLIN12bOGw7M8PpZDJ5sINmNzeFQn4v+q7vFuxhYytHk+6v7
    ne7tuHi9OrlJ7+TG96GVI01h/erk3FM0DgYdmq9M6zCT2pEdqwMoDEyYcygFDw2r0GMgD1
    AMKEoLFiXUcSzYSSdKExYhTyGN6T+3bHuTvyCdM9jxtwdJXWQnWqb1Ey9Hp5HdcjFCBPp/
    ITOXaqn/z3FWu5sGQ9dD6uxLHJ9iyqqwwnD3CLIQES3aeb8SSZVSsNKwKF+A
X-ME-Proxy: <xmx:RhSwak8jSP1zRGadiyLtmvDqdseRohsLJuZuLcL8O14ZD8vfkdS27w>
    <xmx:RxSwauCzFVSDxEs-rGFNzri5D2AVSQdyyhwNqlDzZv8AD2X8wRRXhQ>
    <xmx:RxSwaurah_qMTU4-zdYrDZj3hpfW8FJNCT5vNIux9pTwsqcs2-lNpw>
    <xmx:RxSwanIZ-iCwL-MbR-YkQZlHWSbws-KK0sbPBVru5jAFwnYwHHAGiw>
    <xmx:RxSwagLfllQ9LjXsBYaZtUA9HPDztjAruF5DHAKQj41vbK2GtZaDqt0a>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D0C5F780070; Sun, 20 Sep 2026 13:13:42 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AKy4i6IcFkHk
Date: Sun, 20 Sep 2026 13:13:14 -0400
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
Message-Id: <29ccafd9-22ee-46c9-9049-e188734bc5b3@slotpi15m67>
In-Reply-To: <20260919022441.3305170-15-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
 <20260919022441.3305170-15-neilb@ownmail.net>
Subject: Re: [PATCH v2 14/14] nfsd: use vfs_lookup_open() for non-creating open
 requests too.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, Sep 19, 2026, NeilBrown wrote:
> Now that we have vfs_lookup_open() for open requests which create, we
> can use it for non-creating requests too as vfs_lookup_open() is already
> able to do that.  nfsd4_create_file() is renamed to nfsd4_open_file()
> and enhanced to not always create, and is then used for all OPEN
> requests.

[ ... ]

> As ->op_createmode isn't defined when op_create is zero, we need a
> local createmode which is -1 (illegal value) when op_create is zero.

The code below sets createmode to NFS4_CREATE_UNCHECKED for the
non-creating case, not -1. Is this paragraph left over from v1?

Also, is ->op_createmode really undefined there? nfsd4_decode_open()
starts with memset(open, 0, sizeof(*open)), and NFS4_CREATE_UNCHECKED
is 0, so op_createmode already reads as UNCHECKED for a non-creating
OPEN. If that can be relied on, the local createmode can go away, along
with the op_create test added to do_open_lookup() at the end of this
patch. If the intent is to stop depending on the decoder's memset,
the description should say that instead.


> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 40bd1179bf60..6be6ca473586 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -249,28 +249,30 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
>  }
>
>  /*
> - * Implement NFSv4's unchecked, guarded, and exclusive create
> - * semantics for regular files. Open state for this new file is
> - * subsequently fabricated in nfsd4_process_open2().
> + * Implement NFSv4's open semantics for regular files, both creating
> + * (unchecked, guarded, and exclusive) and non-creating.  The "struct file"
> + * is openned here, and other open state for is subsequently fabricated in
> + * nfsd4_process_open2().

s/openned/opened/, and "other open state for is subsequently" has lost
a word or gained one.


> @@ -359,11 +381,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		iap->ia_atime.tv_nsec = 0;
>  	}
>
> -	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
> -	if (create_status)
> -		/* Might still succeed if no create is needed */
> -		oflags &= ~O_CREAT;
> -
>  	open->op_filp = vfs_lookup_open(&parent,
>  					&QSTR_LEN(open->op_fname,
>  						  open->op_fnamelen),

With every open-by-name now coming through here, does may_open() get
in ahead of nfsd_permission()? For a file that already exists,
vfs_lookup_open()->do_open() calls may_open() with MAY_READ or
MAY_WRITE. The old non-create path was nfsd_lookup(), then
do_open_permission(), and later __nfsd_open()->dentry_open(), which
does not call may_open(). So nfsd_permission() had the only say, and
there are two places where it is deliberately more generous than
inode_permission():

 - do_open_permission() always sets NFSD_MAY_READ_IF_EXEC, so that a
   client can read a mode 0111 binary in order to execute it. Now
   inode_permission(MAY_READ) fails in may_open() before we get that
   far, and the OPEN returns NFS4ERR_ACCESS.

 - do_open_lookup() sets NFSD_MAY_OWNER_OVERRIDE for
   CLAIM_DELEGATE_CUR. That claim type is never a create, so it always
   takes this path. An owner re-opening for write after a chmod 0444
   would fail in may_open().

That is from auditing the code; I have not run either case. I think an
UNCHECKED create that finds an existing file has had the same exposure
since 12/14, but here it becomes the common case. Could
vfs_lookup_open() let the caller skip may_open(), perhaps by passing an
acc_mode of 0 the way do_open() already does for FMODE_CREATED? Or
should the non-creating case stay with nfsd_lookup()?


> @@ -395,14 +412,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		goto out;
>
>  	if (!open->op_created &&
> -	    nfsd4_create_is_exclusive(open->op_createmode) &&
> +	    nfsd4_create_is_exclusive(createmode) &&
>  	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
>  	    inode_get_atime_sec(d_inode(child)) == v_atime &&
>  	    d_inode(child)->i_size == 0)
>  		open->op_created = true;
>
>  	if (!open->op_created) {
> -		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
> +		if (createmode != NFS4_CREATE_UNCHECKED) {
>  			status = nfserr_exist;
>  			goto out;
>  		}

This one is not new here, it arrived with 11/14. This patch makes
it reachable from every non-creating OPEN. Just below this hunk:

		if (unlikely(nfsd_mountpoint(child, fhp->fh_export) == 1)) {
			dget(child);
			nfsd_filp_close(open->op_filp);
			open->op_filp = NULL;
			goto do_cross_mnt;
		}

By this point fh_compose(resfhp, fhp->fh_export, child, fhp) has
already succeeded, and do_cross_mnt calls fh_compose(resfhp, ...) a
second time. When fh_dentry is already set, fh_compose() prints
"fh_compose: fh ... not initialized!" and then overwrites fh_dentry and
fh_export. Does that leak the first dentry and svc_export references?
Would an fh_put(resfhp) before the goto be enough, or is it better to
do the nfsd_mountpoint() check before the first fh_compose()?


> @@ -521,46 +538,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru

> +	/* FIXME: check session persistence and pnfs flags.
> +	 * The nfsv4.1 spec requires the following semantics:
> +	 *
> +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> +	 * Reply Cache  | server |                 |

This table is only about create modes. Out of the op_create block it
now reads as though it applies to every OPEN. Could it say "for
creating OPENs", or move into the op_create arm of nfsd4_open_file()?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
