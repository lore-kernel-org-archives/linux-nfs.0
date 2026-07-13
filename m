Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 966CC2ED870
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 21:46:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783979177; cv=none; b=Mbj05tg+OPNVY27KsY6X8D9ERA6ZSXWpprKbq6ofYYn8eLjjt8d5xhr8AZXgAZU1CKiPVZxGC7dYWvZaJckR5lyxT/32iP48jNfUWJ2mt+qz+k0h7BnQ4ufbe5xIh+K0UzaB5hkBQXH55dHQAzoZkvTO52mpX5fZRlwLu434bMk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783979177; c=relaxed/simple;
	bh=12c56dgirNFWVSedPOYg2lauLgOy091vyONRVIheYUI=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=MqgIAVv6KXSEzdGu/BdH4kqvIUglAnlaXTRooCyRG56+dNex0ivDtnT0/uJNWLAzz/zkInb8Fns1fEKmOMBtcFF6Y1oOqepwXnx/jJears+iWaTZdHKlTg2J2LwJILbUoDoJBaUCEgUL+JiZsJpaWTcDG1w2GG0h9ph44ppOCHg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=EpbfqZnw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ZwJZwq4H; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="EpbfqZnw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZwJZwq4H"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfhigh.stl.internal (Postfix) with ESMTP id B8CA47A0141;
	Mon, 13 Jul 2026 17:46:14 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Mon, 13 Jul 2026 17:46:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1783979174; x=1784065574; bh=qrF6JpH7uP2T2p98TTQy4fePzVRLqEUlGvt
	5Ns24j4I=; b=EpbfqZnwRYWjv3ty1wUT8icPi6NEnUTvKH5u5qo5bz+8HvDNCE/
	06xDfoFiIjRXjXgjXSV8GF+5a+98PeGY3XU9ue45QZqo+DaRHTEPf/wBC/ypfnG4
	LRhriBgq5C7CqpGgabI22zEyAxD6vLG+a0YM9PjUz01upaEsNQEk4sADayN7haVJ
	qcbGmR0wbUmIqGL9xtxDw121Uf4k2KLSZzwGpWPgm6Cd1UyecxF106B+39RMtpre
	OruJrRFkyI/RTtYhc3TvyErO3MbXVQMv9FYjC4fPs8PnKPxpZsf4McxGKL37/B21
	6CrH4iwEgCSdWm3qg6GJsvc6EdsTEUkUQmw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1783979174; x=
	1784065574; bh=qrF6JpH7uP2T2p98TTQy4fePzVRLqEUlGvt5Ns24j4I=; b=Z
	wJZwq4HJsCjr6AF/Rw2J0Y4JA8mKfN3eFasZGC0ceuAnjAduLKvMavDQCCF2C5Dd
	sG8uBXqg8lKVQsfveHez0R0C188JN0+1o0vxlmeYDbkILj5R3SZpUhZ8nwertoF/
	kyUlkmf0so4W3HYA84ioAhnxxfi5qMhLOliLXsBGbPVhrhpBfEI8vjLz6nrUCvVv
	J15SAOg+/crBWjYqdZsi0Hq3zLwh2MzwBaqZfiJLM9OzSny+xRZhHJs/MWcG/f0m
	Tr0ZiGdNFkDcomXXseiHiq9GwoqJLrv0dwE3JYmGohzoLbYc7+I3QQA24e8KkQS0
	LInIQb0HUovsYkKYWWPvw==
X-ME-Sender: <xms:plxVan4HAmJO5B2ZDblVcubhwGx1ulCy88Cpxu5avpPtEP7KlCxhuQ>
    <xme:plxVavJojrhjV2w3X-dri2e5hGhTJ_Umygq7MGT6eUQoeVax0oQ1Wd1stnwppV9Ha
    UVN-63h74wfclPdCdV9MG4ma4sMGN8Qgvofzor--Lz3eC5nIZ4>
X-ME-Received: <xmr:plxVagv3Rw18gdNMKvXjPCetxESNgDRzpYJ-ylcMwUKndNgKDCjAYqq4kzzQ68F8Gg2aNOLHrjcynRtTuivH9prTPnXii0w>
X-ME-Proxy-Cause: dmFkZTFEMx3X+qcdIoQ+BuzqeLDi62EQ9Og0dMltURwm5b4eUYxntyurvPv0Jfrk7BCOUb
    elnbuJtfTMmuc8wSQI1G+5iW+KMJcPVHi8+AN4qkvrri132S6WYf739l0ALTLRwSHRFt3i
    xLncGdHS6nXsGrYybSOkIr36eOVTUsZ/+vt/e5FRQ7tC1WZqxblvwUfdcK/ParcTeDGW+V
    CGIrU5XSkNuXhM7owZcs97D6XArQuKC/ncXTkukTVlnEewqEotbcqALRCaZXKgvGd5UAXd
    pe7GcRN2y0BI8hhAY28pJHHlEf7Nu901xeqn5CHBFDBFRzXN8qfa0/AfjaouA4D9CwprUP
    EHL6rmxinNNnoguIz3h+znJecxhPLgUSwmhagJ/T8xp/VJQyaOzhjZ36p3BIoowTxJzcjE
    kjDjYCAoe7LHPpIalvRXumol2m0tqEhVFBAptyyhm2wqVTGrRTD66OC2vKfY8tX9LMNQCM
    JuCW46cszszNXVsJAqvoV9jej6KTsgcvxJGrRIKUmhgKyHQ8cO3N1UsxV4iVhMmix5h1jQ
    wf85PFpdE8wZ1Vxgal0uWmnIeZsliuwvg8lqPpqyl2Jh8DVXXMoUeuezq2cOc6lo2jm2v8
    sQUpYQActtv25HxMmzjnIm6WVHNX5cJem2shj6XOW7vQWZrrhHFBBcrEwWTQ
X-ME-Proxy: <xmx:plxVauJ_ayY4fPbE8cRrbZjipdheaqwaMkHGY-DssjXSyl8TyJk06Q>
    <xmx:plxVap9TtxgxN0roMYgsqx_QMn2qCMPvgidcQF2-e7BK4TBPdtgaaA>
    <xmx:plxVanzUEIadWgtPedX5oa3O-tRkgEHv4nHVkeYVruZ580eG6jXHXQ>
    <xmx:plxVam48PBITR8BOc-KFUWHCMrzhdbT98I6ehJHGmVH9z35LGtOGMw>
    <xmx:plxVai2xqzezo01C3HCT6q51O_KsBOGpQ-H6H_tq7KlIAxQYGHXH3ohk>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 13 Jul 2026 17:46:12 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v3 02/17] nfsd: correctly handle CREATE of mounted-on files
In-reply-to: <2cf15b2e-639c-400f-9a60-7bb030c97762@app.fastmail.com>
References: <20260713062219.6399-1-neilb@ownmail.net>
  <20260713062219.6399-3-neilb@ownmail.net>
  <2cf15b2e-639c-400f-9a60-7bb030c97762@app.fastmail.com>
Date: Tue, 14 Jul 2026 07:46:09 +1000
Message-id: <178397916992.3371781.8793041168044019909@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 13 Jul 2026, Chuck Lever wrote:
> Hi Neil-
> 
> On Mon, Jul 13, 2026, at 2:15 AM, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >
> > Linux allows a file (non-directory) to be mounted on a file.  nfsd
> > mostly supports this if the crossmnt option is in effect.  However if
> > CREATE is used on an existing mounted-on file, the filehandle for the
> > underlying file is returns.  The client will then continue to use that
> > filehandle.
> >
> > So
> >   cat /mnt/file
> > will show the contents of the mounted file as expected, but if
> > the dcache is flushed with "drop_caches" or similar, then
> >   >> /mnt/file
> >   cat /mnt/file
> > will show the mounted-on file.
> >
> > For exclusive or checked creates this is not a problem as the creation
> > will fail no matter which file is seen. For unchecked creates we need to
> > see if the name is in the dcache, and if it is mounted.  If so, we
> > simply provide that filehandle, possibly truncating.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
> 
> I didn't see issues in the other patches in this series, but this
> new one does have some correctness issues. This one doesn't build
> here with CONFIG_NFSD_V2=y, and the NFSv2 and NFSv3 create paths
> have some refcount and behavior problems. The NFSv4 path looks
> good.
> 
> Big picture: the three create paths now handle an existing
> mounted-on file three different ways. v4 sets op_truncate for
> size-zero truncation only, v3 applies the full client iattr, and
> v2 applies nothing.  The v4 behavior is the one I prefer, so
> bring v2 and v3 into line with it.
> 
> Specifics below.
> 
> 
> > diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> > index bbaef884f893..20eaf56fa9e7 100644
> > --- a/fs/nfsd/nfs3proc.c
> > +++ b/fs/nfsd/nfs3proc.c
> > @@ -303,6 +303,34 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct 
> > svc_fh *fhp,
> >  	parent = fhp->fh_dentry;
> >  	inode = d_inode(parent);
> > 
> > +	if (argp->createmode == NFS3_CREATE_UNCHECKED) {
> > +		/*
> > +		 * If name is already in dcache we need to check for mountpoints
> > +		 */
> > +		child = try_lookup_noperm(&QSTR_LEN(argp->name,
> > +						    argp->len),
> > +					  parent);
> > +		if (child && !IS_ERR(child) && d_is_reg(child) &&
> > +		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
> > +			struct svc_export *exp = exp_get(fhp->fh_export);
> > +			if (nfsd_cross_mnt(rqstp, &child, &exp) == 0) {
> > +				status = check_nfsd_access(exp, rqstp, false);
> > +				if (status == nfs_ok)
> > +					status = fh_compose(resfhp, exp,
> > +							    child, fhp);
> > +				if (status == nfs_ok)
> > +					status = nfsd_create_setattr(
> > +						rqstp, fhp, resfhp, &attrs);
> > +				dput(child);
> > +				exp_put(exp);
> > +				return status;
> > +			}
> > +			exp_put(exp);
> > +		}
> > +		if (!IS_ERR(child))
> > +			dput(child);
> > +	}
> > +
> >  	host_err = fh_want_write(fhp);
> >  	if (host_err)
> >  		return nfserrno(host_err);
> 
> The ordinary UNCHECKED path masks iap->ia_valid to ATTR_SIZE before
> calling nfsd_create_setattr(). This branch passes the full client
> iattr, so it applies atime/mtime to the existing mounted-on file
> that the ordinary create path drops. Mask to ATTR_SIZE here too.
> 
> 
> > diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> > index f60043632575..549eed8f2c19 100644
> > --- a/fs/nfsd/nfsproc.c
> > +++ b/fs/nfsd/nfsproc.c
> > @@ -302,11 +302,34 @@ nfsd_proc_create(struct svc_rqst *rqstp)
> >  	if (resp->status != nfs_ok)
> >  		goto done; /* must fh_put dirfhp even on error */
> > 
> > +	fh_init(newfhp, NFS_FHSIZE);
> > +
> >  	/* Check for NFSD_MAY_WRITE in nfsd_create if necessary */
> > 
> >  	resp->status = nfserr_exist;
> >  	if (name_is_dot_dotdot(argp->name, argp->len))
> >  		goto done;
> > +
> > +	/*
> > +	 * If name is already in dcache we need to check for mountpoints
> > +	 */
> > +	dchild = try_lookup_noperm(&QSTR_LEN(argp->name, argp->len),
> > +				   dirfhp->fh_export);
> > +	if (dchild && !IS_ERR(dchild) && d_is_reg(child) &&
> > +	    unlikely(nfsd_mountpoint(dchild, fhp->fh_export))) {
> 
> This hunk does not compile with CONFIG_NFSD_V2=y.
> 
> 
> > +		struct svc_export *exp = fhp->fh_export;
> > +		if (nfsd_cross_mnt(rqstp, &dchild, &exp) == 0 &&
> > +		    d_isreg(dchild)) {
> 
> nfsd_cross_mnt() drops a reference on the export it is given and
> returns referenced replacements in dchild and exp. This branch
> hands it the filehandle's borrowed fh_export with no exp_get(),
> so a successful crossing underflows the export refcount. It then
> jumps to done without releasing either replacement, leaking dchild
> and exp. The v3 and v4 hunks get this right: exp_get() first,
> dput(child) and exp_put(exp) after.
> 
> 
> > +			resp->status = check_nfsd_access(exp, rqstp, false);
> > +			if (resp->status == nfs_ok)
> > +				resp->status = fh_compose(newfhp, dirfhp->fh_export,
> > +							  dchild, dirfhp);
> 
> After the crossing, dchild is on the mounted filesystem, which exp
> describes, not dirfhp->fh_export. Thus fh_compose() must use exp
> here.
> 
> 
> > +			goto done;
> 
> The normal v2 path truncates an existing regular file: it masks to
> ATTR_SIZE and calls nfsd_setattr(). This branch returns without
> truncating, so an UNCHECKED create with size zero leaves the
> mounted-on file's contents intact.
> 
> 
> Lastly, should we consider this patch for backporting to LTS? If
> so, I'm guessing the issues it fixes were introduced at different
> points in the commit history, so this patch would have to be split
> accordingly. (If no backporting is necessary, then it can remain
> as a single patch).

Thanks for the review! I'll develop some fixes in a day or 3.
I wouldn't bother back poring.  This is not a regression and is not
exploitable.

This has *never* worked correctly.  CREATE has *always* ignored mounts.
unchecked-create is unique in that it doesn't fail with -EEXIST, but
succeeds without having gone through nfsd_lookup().
Maybe I should try to refactor nfsd_lookup() and use the same code...

Thanks,
NeilBrown

