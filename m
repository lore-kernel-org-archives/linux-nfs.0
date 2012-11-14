Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45891 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756056Ab2KNA6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 19:58:24 -0500
Date: Tue, 13 Nov 2012 19:58:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121114005815.GA23604@fieldses.org>
References: <20121109200730.GI6171@fieldses.org>
 <E1TWxKX-00025I-J2@diesel.geggus.net>
 <20121109232410.GK6171@fieldses.org>
 <20121112091717.GA1610@geggus.net>
 <20121113224005.GA11545@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121113224005.GA11545@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 13, 2012 at 05:40:05PM -0500, J. Bruce Fields wrote:
> On Mon, Nov 12, 2012 at 10:17:17AM +0100, Sven Geggus wrote:
> > J. Bruce Fields schrieb am Samstag, den 10. November um 00:24 Uhr:
> > 
> > OK, back at work and here is what I get:
> > 
> > > Restart the server, start strace, then try the mount, let it hang a few
> > > seconds just to make sure you got anything interesting, then kill strace
> > > and send the output.
> > 
> > OK, back at work and here is what I get...
> > 
> > read(3, "nfsd 10.1.7.30\n", 2048)       = 15
> > close(15)                               = 0
> > open("/var/lib/nfs/etab", O_RDONLY)     = 15
> > close(15)                               = 0
> > close(15)                               = 0
> > write(3, "nfsd 10.1.7.30 1352710828 * \n", 29) = 29
> > read(4, "4294967295\n", 2048)           = 11
> > close(16)                               = 0
> > close(15)                               = 0
> > read(15,
> > "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0",
> > 36) = 36
> > close(15)                               = 0
> > write(4, "4294967295 1352710828 0 \n", 25) = -1 EINVAL (Invalid argument)
> 
> I suspect that error's coming from
> net/sunrpc/svcauth_unix.c:unix_gid_parse().
> 
> > 4294967295 is UINT_MAX and this place is where it behaves differently on a good
> > kernel where the write call will succeed:
> > 
> > write(4, "4294967295 1352710828 0 \n", 25) = 25
> > 
> > Sven
> > 
> > P.S.: Your patched svcauth_gss.c will give me an "access denied by server"
> > while mounting instead of the infinite delay:
> >  ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/
> > mount.nfs4: access denied by server while mounting testsrv:/storage
> 
> So, looks like the same get_int problem exists in several other places.
> Could you try the following instead of the previous patch?  I think I
> got them all this time....

Oh, cripes, but this isn't good enough--svcgssd actually passes down -1
id's.  Ugh--I'll take a closer look tomorrow.

--b.

> 
> --b.
> 
> commit 664f26313a738f539a32c4eadd5351905e301bf2
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Nov 9 15:16:02 2012 -0500
> 
>     svcrpc: fix parsing of uids and gids in gss contexts
>     
>     bbf43dc888833ac0539e437dbaeb28bfd4fbab9f "sunrpc/cache.h: replace
>     simple_strtoul" introduced new range-checking which could cause get_int
>     to fail if given an unsigned integer too large to represent as an int.
>     
>     Symptoms were hangs on krb5 mounts after upgrading an NFS server.
>     
>     Cc: Eldad Zack <eldad@fogrefinery.com>
>     Reported-by: Sven Geggus <lists@fuchsschwanzdomain.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index a3946cf..8481961 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -491,7 +491,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  	int err;
>  	struct auth_domain *dom = NULL;
>  	struct svc_export exp = {}, *expp;
> -	int an_int;
> +	unsigned int an_int;
>  
>  	if (mesg[mlen-1] != '\n')
>  		return -EINVAL;
> @@ -531,7 +531,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		goto out3;
>  
>  	/* flags */
> -	err = get_int(&mesg, &an_int);
> +	err = get_uint(&mesg, &an_int);
>  	if (err == -ENOENT) {
>  		err = 0;
>  		set_bit(CACHE_NEGATIVE, &exp.h.flags);
> @@ -541,19 +541,19 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		exp.ex_flags= an_int;
>  	
>  		/* anon uid */
> -		err = get_int(&mesg, &an_int);
> +		err = get_uint(&mesg, &an_int);
>  		if (err)
>  			goto out3;
>  		exp.ex_anon_uid= an_int;
>  
>  		/* anon gid */
> -		err = get_int(&mesg, &an_int);
> +		err = get_uint(&mesg, &an_int);
>  		if (err)
>  			goto out3;
>  		exp.ex_anon_gid= an_int;
>  
>  		/* fsid */
> -		err = get_int(&mesg, &an_int);
> +		err = get_uint(&mesg, &an_int);
>  		if (err)
>  			goto out3;
>  		exp.ex_fsid = an_int;
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index a1f10c0..e2c9317 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -415,7 +415,7 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
>  		goto out;
>  
>  	/* ID */
> -	error = get_int(&buf, &ent.id);
> +	error = get_uint(&buf, &ent.id);
>  	if (error == -EINVAL)
>  		goto out;
>  	if (error == -ENOENT)
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 73e9573..243d180 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -444,7 +444,7 @@ static int rsc_parse(struct cache_detail *cd,
>  		goto out;
>  
>  	/* uid, or NEGATIVE */
> -	rv = get_int(&mesg, &rsci.cred.cr_uid);
> +	rv = get_uint(&mesg, &rsci.cred.cr_uid);
>  	if (rv == -EINVAL)
>  		goto out;
>  	if (rv == -ENOENT)
> @@ -453,7 +453,7 @@ static int rsc_parse(struct cache_detail *cd,
>  		int N, i;
>  
>  		/* gid */
> -		if (get_int(&mesg, &rsci.cred.cr_gid))
> +		if (get_uint(&mesg, &rsci.cred.cr_gid))
>  			goto out;
>  
>  		/* number of additional gid's */
> @@ -469,7 +469,7 @@ static int rsc_parse(struct cache_detail *cd,
>  		for (i=0; i<N; i++) {
>  			gid_t gid;
>  			kgid_t kgid;
> -			if (get_int(&mesg, &gid))
> +			if (get_uint(&mesg, &gid))
>  				goto out;
>  			kgid = make_kgid(&init_user_ns, gid);
>  			if (!gid_valid(kgid))
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 4d01292..5d7020a 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -493,7 +493,7 @@ static int unix_gid_parse(struct cache_detail *cd,
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> -	rv = get_int(&mesg, &uid);
> +	rv = get_uint(&mesg, &uid);
>  	if (rv)
>  		return -EINVAL;
>  	ug.uid = uid;
> @@ -513,7 +513,7 @@ static int unix_gid_parse(struct cache_detail *cd,
>  	for (i = 0 ; i < gids ; i++) {
>  		int gid;
>  		kgid_t kgid;
> -		rv = get_int(&mesg, &gid);
> +		rv = get_uint(&mesg, &gid);
>  		err = -EINVAL;
>  		if (rv)
>  			goto out;
