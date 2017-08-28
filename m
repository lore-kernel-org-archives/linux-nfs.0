Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47652 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750787AbdH1EdD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Aug 2017 00:33:03 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 14:32:53 +1000
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 3/3] nfsd: clients don't need to break their own delegations
In-Reply-To: <1503697958-6122-4-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-4-git-send-email-bfields@redhat.com>
Message-ID: <87bmn0ia6i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25 2017, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>
> We currently revoke read delegations on any write open or any operation
> that modifies file data or metadata (including rename, link, and
> unlink).  But if the delegation in question is the only read delegation
> and is held by the client performing the operation, that's not really
> necessary.
>
> It's not always possible to prevent this in the NFSv4.0 case, because
> there's not always a way to determine which client an NFSv4.0 delegation
> came from.  (In theory we could try to guess this from the transport
> layer, e.g., by assuming all traffic on a given TCP connection comes
> from the same client.  But that's not really correct.)
>
> In the NFSv4.1 case the session layer always tells us the client.
>
> This patch should remove such self-conflicts in all cases where we can
> reliably determine the client from the compound.

I don't see any mention of the new DELEG_NO_WAIT, either here or where
the value is defined.  That means I have to figure it out for myself?


>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  Documentation/filesystems/Locking |  2 ++
>  fs/locks.c                        |  7 ++++++-
>  fs/nfsd/nfs4state.c               | 40 +++++++++++++++++++++++++++++++++=
++++++
>  fs/nfsd/vfs.c                     | 26 ++++++++++++++++++++-----
>  include/linux/fs.h                | 27 ++++++++++++++++----------
>  5 files changed, 86 insertions(+), 16 deletions(-)
>
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystem=
s/Locking
> index fe25787ff6d4..8876a32df5ff 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -366,6 +366,7 @@ prototypes:
>  	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
>  	void (*lm_break)(struct file_lock *); /* break_lease callback */
>  	int (*lm_change)(struct file_lock **, int);
> +	bool (*lm_breaker_owns_lease)(void *, struct file_lock *);
>=20=20
>  locking rules:
>=20=20
> @@ -376,6 +377,7 @@ lm_notify:		yes		yes			no
>  lm_grant:		no		no			no
>  lm_break:		yes		no			no
>  lm_change		yes		no			no
> +lm_breaker_owns_lease:	no		no			no
>=20=20
>  [1]:	->lm_compare_owner and ->lm_owner_key are generally called with
>  *an* inode->i_lock held. It may not be the i_lock of the inode
> diff --git a/fs/locks.c b/fs/locks.c
> index afefeb4ad6de..a3de5b96c81c 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1404,6 +1404,9 @@ static void time_out_leases(struct inode *inode, st=
ruct list_head *dispose)
>=20=20
>  static bool leases_conflict(struct file_lock *lease, struct file_lock *b=
reaker)
>  {
> +	if (lease->fl_lmops->lm_breaker_owns_lease && breaker->fl_owner &&
> +	    lease->fl_lmops->lm_breaker_owns_lease(breaker->fl_owner, lease))
> +		return false;
>  	if ((breaker->fl_flags & FL_LAYOUT) !=3D (lease->fl_flags & FL_LAYOUT))
>  		return false;
>  	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
> @@ -1429,6 +1432,7 @@ any_leases_conflict(struct inode *inode, struct fil=
e_lock *breaker)
>  /**
>   *	__break_lease	-	revoke all outstanding leases on file
>   *	@inode: the inode of the file to return
> + *	@who: if an nfs client is breaking, which client it is
>   *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
>   *	    break all leases
>   *	@type: FL_LEASE: break leases and delegations; FL_DELEG: break
> @@ -1439,7 +1443,7 @@ any_leases_conflict(struct inode *inode, struct fil=
e_lock *breaker)
>   *	a call to open() or truncate().  This function can sleep unless you
>   *	specified %O_NONBLOCK to your open().
>   */
> -int __break_lease(struct inode *inode, unsigned int mode, unsigned int t=
ype)
> +int __break_lease(struct inode *inode, void *who, unsigned int mode, uns=
igned int type)
>  {
>  	int error =3D 0;
>  	struct file_lock_context *ctx;
> @@ -1452,6 +1456,7 @@ int __break_lease(struct inode *inode, unsigned int=
 mode, unsigned int type)
>  	if (IS_ERR(new_fl))
>  		return PTR_ERR(new_fl);
>  	new_fl->fl_flags =3D type;
> +	new_fl->fl_owner =3D who;

When I saw this, I thought: "Shouldn't 'who' be 'fl_owner_t' rather that
'void*'".
Then I saw

/* legacy typedef, should eventually be removed */
typedef void *fl_owner_t;


Maybe you could do the world a favor and remove fl_owner_t in a
preliminary patch :-)


And it is kind-a weird that the "who" you pass to break_lease() is
different from the owner passed to vfs_setlease().

>=20=20
>  	/* typically we will check that ctx is non-NULL before calling */
>  	ctx =3D smp_load_acquire(&inode->i_flctx);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0c04f81aa63b..fb15efcc4e08 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3825,6 +3825,45 @@ nfsd_break_deleg_cb(struct file_lock *fl)
>  	return ret;
>  }
>=20=20
> +static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
> +{
> +	struct nfsd4_compoundres *resp;
> +
> +	/*
> +	 * In case it's possible we could be called from NLM or ACL
> +	 * code?:
> +	 */
> +	if (rqst->rq_prog !=3D NFS_PROGRAM)
> +		return NULL;
> +	if (rqst->rq_vers !=3D 4)
> +		return NULL;
> +	resp =3D rqst->rq_resp;
> +	return resp->cstate.clp;
> +}
> +
> +static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
> +{
> +	struct svc_rqst *rqst =3D who;
> +	struct nfs4_client *cl;
> +	struct nfs4_delegation *dl;
> +	struct nfs4_file *fi =3D (struct nfs4_file *)fl->fl_owner;
> +	bool ret =3D true;
> +
> +	cl =3D nfsd4_client_from_rqst(rqst);
> +	if (!cl)
> +		return false;
> +
> +	spin_lock(&fi->fi_lock);
> +	list_for_each_entry(dl, &fi->fi_delegations, dl_perfile) {
> +		if (dl->dl_stid.sc_client !=3D cl) {
> +			ret =3D false;
> +			break;
> +		}
> +	}
> +	spin_unlock(&fi->fi_lock);
> +	return ret;
> +}

You haven't provided any documentation telling me what the
"lm_breaker_owns_lease" callback is meant to do.
So I look at this one piece of sample code -- it seems to compute:
  not (an other client owns lease)
rather than
  (this client owns lease)
which is what I would have expected.

Given that any_leases_conflict() already loops over all leases, does
nfsd_breaker_owns_lease() need to loop as well?
Or does nfsd only take a single lease to cover all the delegations to
all the clients?
... hmmm, yes that does seem to be how nfsd works.

Would this all turn out to be easier if nfsd took a separate lease for
each client?  What would be the cost of that?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmjnPcACgkQOeye3VZi
gblW0Q//dzHmjC7WhR1OaQ8ghgUvs7nxoZv/+FE7Zlh71jyN+Cnq+Fn7HA03uufu
LT+DUdJqTQZVf8BTNIbZxoDPU9xCP1deBmvusLQRcbiNnQGJFTJloNydORxMGOsz
Oax1Eb/xzkBn8l6V5CNCHrEmDWCYrLn+pKGrGRBHHkQMICEjrk5piXaCIpCi3LTi
39uin9+KMUzXbvSY3TX3yltMcFzvM3gzU1MjfTAG+YDE5hke2vy1k99MCMJu/ymc
Y04dDZfh0RgbtMmkm8qoQTtF8sOBpAdtaDymMl17zw+fXFHnTyAFH6ItiYq4bnlw
ml8jKGy7FiclvfAiN9CHgyfjayf6pN9u6q+nrdDnw1UFN9avg/drl0OtjrhSaNjm
B/5RcOj0c3Gyt4OTcFIji25nUt3mnb05fObHL+p1rYPHo8yYm/J7Yac+nNcOk05j
nXXLwawUPwf/DHBM4lEyrQ+B4f21r7SyJrja3ldwsgr1z0aS9l9WIiecbhUaZSXP
5qkBzpPIWQeNlbAIij5nw+6ZTaMVhvID7f8ne9ocmxMncKekaHvGtN3YMv1XnQF9
mXbsvsdr+wOImSUbF2ByxetAeF4++iItO9X9RwPyYWgaSS8TdjoG0NAM3rhjcYJW
nRLNoAMpn7yGVhMmA6AqmNuoBS2Ewi8ANQn1BHSXe1gHVCyrxWo=
=rzRV
-----END PGP SIGNATURE-----
--=-=-=--
