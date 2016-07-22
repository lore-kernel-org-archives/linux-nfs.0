Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44857 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbcGVCkg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 22:40:36 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 22 Jul 2016 12:40:26 +1000
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] Btrfs: be more precise on errors when getting an inode from disk
In-Reply-To: <20160722015904.GB29969@fieldses.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org> <874m7i8oou.fsf@notabene.neil.brown.name> <20160722015904.GB29969@fieldses.org>
Message-ID: <87bn1q75ut.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 22 2016, J. Bruce Fields wrote:

> On Fri, Jul 22, 2016 at 11:08:17AM +1000, NeilBrown wrote:
>> On Fri, Jun 10 2016, fdmanana@kernel.org wrote:
>>=20
>> > From: Filipe Manana <fdmanana@suse.com>
>> >
>> > When we attempt to read an inode from disk, we end up always returning=
 an
>> > -ESTALE error to the caller regardless of the actual failure reason, w=
hich
>> > can be an out of memory problem (when allocating a path), some error f=
ound
>> > when reading from the fs/subvolume btree (like a genuine IO error) or =
the
>> > inode does not exists. So lets start returning the real error code to =
the
>> > callers so that they don't treat all -ESTALE errors as meaning that the
>> > inode does not exists (such as during orphan cleanup). This will also =
be
>> > needed for a subsequent patch in the same series dealing with a special
>> > fsync case.
>> >
>> > Signed-off-by: Filipe Manana <fdmanana@suse.com>
>>=20
>> SNIP
>>=20
>> > @@ -5594,7 +5602,8 @@ struct inode *btrfs_iget(struct super_block *s, =
struct btrfs_key *location,
>> >  		} else {
>> >  			unlock_new_inode(inode);
>> >  			iput(inode);
>> > -			inode =3D ERR_PTR(-ESTALE);
>> > +			ASSERT(ret < 0);
>> > +			inode =3D ERR_PTR(ret < 0 ? ret : -ESTALE);
>> >  		}
>>=20
>> Just a heads-up.  This change breaks NFS :-(
>>=20
>> The change in error code percolates up the call chain:
>>=20
>>  nfs4_pufh->fh_verify->nfsd_set_fh_dentry->exportfs_decode_fh
>>     ->btrfs_fh_to_dentry->ntrfs_get_dentry->btrfs_iget
>>=20
>> and nfsd returns NFS4ERR_NOENT to the client instead of NFS4ERR_STALE,
>> and the client doesn't handle that quite the same way.
>>=20
>> This doesn't mean that the change is wrong, but it could mean we need to
>> fix something else in the path to sanitize the error code.
>>=20
>> nfsd_set_fh_dentry already has
>>=20
>> 	error =3D nfserr_stale;
>> 	if (PTR_ERR(exp) =3D=3D -ENOENT)
>> 		return error;
>>=20
>> 	if (IS_ERR(exp))
>> 		return nfserrno(PTR_ERR(exp));
>>=20
>> for a different error case, so duplicating that would work, but I doubt
>> it is best.  At the very least we should check for valid errors, not
>> specific invalid ones.
>>=20
>> Bruce: do you have an opinion where we should make sure that PUTFH (and
>> various other requests) returns a valid error code?
>
> Uh, I guess not.  Maybe exportfs_decode_fh?
>
> Though my kneejerk reaction is to be cranky and wonder why btrfs
> suddenly needs a different convention for decode_fh().
>

I can certainly agree with that perspective, though it would be
appropriate in that case to make sure we document the requirements for
fh_to_dentry (the current spelling for 'decode_fh').  So I went looking
for documentation and found:

 * fh_to_dentry:
 *    @fh_to_dentry is given a &struct super_block (@sb) and a file handle
 *    fragment (@fh, @fh_len). It should return a &struct dentry which refe=
rs
 *    to the same file that the file handle fragment refers to.  If it cann=
ot,
 *    it should return a %NULL pointer if the file was found but no accepta=
ble
 *    &dentries were available, or an %ERR_PTR error code indicating why it
 *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry can=
 be
 *    returned including, if necessary, a new dentry created with d_alloc_r=
oot.
 *    The caller can then find any other extant dentries by following the
 *    d_alias links.
 *

So the new btrfs code is actually conformant!!
That documentation dates back to 2002 when I wrote it....
And it looks like ENOENT wasn't handled correctly then :-(

I suspect anything that isn't ENOMEM should be converted to ESTALE.
ENOMEM causes the client to be asked to retry the request later.

Does this look reasonable to you?
(Adding Christof as he as contributed a lot to exportfs)

If there is agreement I'll test and post a proper patch.

Thanks,
NeilBrown


diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 207ba8d627ca..3527b58cd5bc 100644
=2D-- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -428,10 +428,10 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mn=
t, struct fid *fid,
 	if (!nop || !nop->fh_to_dentry)
 		return ERR_PTR(-ESTALE);
 	result =3D nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
=2D	if (!result)
=2D		result =3D ERR_PTR(-ESTALE);
=2D	if (IS_ERR(result))
=2D		return result;
+	if (PTR_ERR(result) =3D=3D -ENOMEM)
+		return ERR_CAST(result)
+	if (IS_ERR_OR_NULL(result))
+		return ERR_PTR(-ESTALE);
=20
 	if (d_is_dir(result)) {
 		/*
@@ -541,6 +541,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt,=
 struct fid *fid,
=20
  err_result:
 	dput(result);
+	if (err !=3D -ENOMEM)
+		err =3D -ESTALE;
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(exportfs_decode_fh);

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkYeaAAoJEDnsnt1WYoG5PrAQAKTwx8yo8YLNx2gOoN1woA4p
XX/2VVJ4c8Yb66CAz58LmbjAvUCRDL2OBfRFv6iffhbWUkEtCfKRGGTiuwA/bAib
JgZvPyWTipnQGcNTYlb3iAc22i3+SXvyJ5Dviorn1CbzuTmvCycziMTmEghJfRCn
x3tDsr+PId+4akVIzK2WIn4qhPbPzqwdDUQuCPdjLvhXdhQOtv665YHF2cgqzsHj
UUs/N3aAjIMnyYu6p/Tv7wEPLjq0CTPfUEor4t3Pe2Eok+EdYj0h1dELfx2n+eRt
TZ1T22p8dK4VA73alm2G8JrGKW1IjAJADT1lsX0IMCtAB/So9kulPxmhTHW9fPLP
/jYI4SbSxRrtkoM7EmHiNA2gWq/2rscrzcWQWZKdgTCM27+HeE376gYDqYSbQRmT
cLCjyGXQmz1MySz0yQiGkO3ZAGhIJJcNACEMl4WniFQCrEpN83R6xJtyKCKQLp1W
wf1BVv1ib6og01p+OL4pKdiqWvzJHAv5fZ0tJALgKMbyR7uoND/f/jXphaC57qcR
nFwfZ99dlLQm1m0ClaHouO4qCTAhr0MO+EwboeqmeKhcE1xj/fofgXU7hCNkYTJn
Wp1WuSgyWcEKmkcMYdZwjNMpk8OhIkdwN/fPQp0ghsSNP35ZQb2b5zRD7uUVZbfW
ELyZ5eaz56VZslE5yQI9
=DHLT
-----END PGP SIGNATURE-----
--=-=-=--
