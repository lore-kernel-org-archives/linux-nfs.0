Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41824 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbcGVBI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 21:08:26 -0400
From: NeilBrown <neilb@suse.com>
To: fdmanana@kernel.org, linux-btrfs@vger.kernel.org
Date: Fri, 22 Jul 2016 11:08:17 +1000
Subject: Re: [PATCH 1/2] Btrfs: be more precise on errors when getting an inode from disk
In-Reply-To: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS List <linux-nfs@vger.kernel.org>
Message-ID: <874m7i8oou.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Jun 10 2016, fdmanana@kernel.org wrote:

> From: Filipe Manana <fdmanana@suse.com>
>
> When we attempt to read an inode from disk, we end up always returning an
> -ESTALE error to the caller regardless of the actual failure reason, which
> can be an out of memory problem (when allocating a path), some error found
> when reading from the fs/subvolume btree (like a genuine IO error) or the
> inode does not exists. So lets start returning the real error code to the
> callers so that they don't treat all -ESTALE errors as meaning that the
> inode does not exists (such as during orphan cleanup). This will also be
> needed for a subsequent patch in the same series dealing with a special
> fsync case.
>
> Signed-off-by: Filipe Manana <fdmanana@suse.com>

SNIP

> @@ -5594,7 +5602,8 @@ struct inode *btrfs_iget(struct super_block *s, struct btrfs_key *location,
>  		} else {
>  			unlock_new_inode(inode);
>  			iput(inode);
> -			inode = ERR_PTR(-ESTALE);
> +			ASSERT(ret < 0);
> +			inode = ERR_PTR(ret < 0 ? ret : -ESTALE);
>  		}

Just a heads-up.  This change breaks NFS :-(

The change in error code percolates up the call chain:

 nfs4_pufh->fh_verify->nfsd_set_fh_dentry->exportfs_decode_fh
    ->btrfs_fh_to_dentry->ntrfs_get_dentry->btrfs_iget

and nfsd returns NFS4ERR_NOENT to the client instead of NFS4ERR_STALE,
and the client doesn't handle that quite the same way.

This doesn't mean that the change is wrong, but it could mean we need to
fix something else in the path to sanitize the error code.

nfsd_set_fh_dentry already has

	error = nfserr_stale;
	if (PTR_ERR(exp) == -ENOENT)
		return error;

	if (IS_ERR(exp))
		return nfserrno(PTR_ERR(exp));

for a different error case, so duplicating that would work, but I doubt
it is best.  At the very least we should check for valid errors, not
specific invalid ones.

Bruce: do you have an opinion where we should make sure that PUTFH (and
various other requests) returns a valid error code?

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkXIBAAoJEDnsnt1WYoG53YEP/isd1/OEdAeU+zNPnKlYXbEx
ZTOH14kU3spsiuIF7D3dm793zrvqdZ28ZNzE/8ay6FgmL7BaX90ZM9WQOfszOrOC
z3KGvcNmk0KyggJW63+keAk8jY/3Avy8ebgvYcwxhPIN2yHaxXHXSlvCzpNNzb4C
d2ek7hd8pmylzDx14FeTtF/wqYdTF+bLVeVncGTHnNWUBLNAc9VB6ld1G6kblJMv
p3xXHl7PBX66kxAvSdF17ExbTXxCY+J9b5gaAtGfRWPvGnF1Lq4BnMugduzP3DXd
hp8Eo5XWxUKaxfx/iYXgxjpDRXBtTRuD/RdkDbwM1y31jtofQvAT6LkoQvKtoArV
ANdDzLEimudVB0ceM5WhqPL/Oiiw1makud7opb9vsV1+HbuKNN8yjFU9+XjpNsPb
iQZPQUZKzGvkkYqU7GpQXZo6GAfbTTUFw+3wk5g506Ye3+U5z3HpDv+UTdIjhDME
qoBSGQVPms3ffp50GW3+4c8vTRECP7PSCPv9NxRArVv3fC1IRsf/ZvOC5Mpq1BVE
8n7OhZCE6rpM/LUnO9rffxpOst+ii24o/8IbIVjXyOas5sskQ14EyT0a8ruBe2xz
WOUwr6m4eszDWL8EbNiQWncjePuSUS4UZ3elU9rh5mHbR1S9216L1gwn3KV/7pfD
Vyq8wlYy3gdyIREP2vWj
=WfFx
-----END PGP SIGNATURE-----
--=-=-=--
