Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57148 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964965AbcHEAvu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 20:51:50 -0400
From: NeilBrown <neilb@suse.com>
To: Christoph Hellwig <hch@infradead.org>
Date: Fri, 05 Aug 2016 10:51:10 +1000
Cc: "J. Bruce Fields" <bfields@fieldses.org>, fdmanana@kernel.org,
        linux-btrfs@vger.kernel.org, NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: be careful to only return expected errors.
In-Reply-To: <20160804124719.GA5676@infradead.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org> <874m7i8oou.fsf@notabene.neil.brown.name> <20160722015904.GB29969@fieldses.org> <87bn1q75ut.fsf@notabene.neil.brown.name> <20160722200843.GA7463@fieldses.org> <877fbxperp.fsf@notabene.neil.brown.name> <20160804124719.GA5676@infradead.org>
Message-ID: <877fbwnim9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04 2016, Christoph Hellwig wrote:

> On Thu, Aug 04, 2016 at 10:19:06AM +1000, NeilBrown wrote:
>>=20
>>=20
>> When nfsd calls fh_to_dentry, it expect ESTALE or ENOMEM as errors.
>> In particular it can be tempting to return ENOENT, but this is not
>> handled well by nfsd.
>>=20
>> Rather than requiring strict adherence to error code code filesystems,
>> treat all unexpected error codes the same as ESTALE.  This is safest.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> I didn't add a dprintk for unexpected error messages, partly
>> because dprintk isn't usable in exportfs.  I could have used pr_debug()
>> but I really didn't see much value.
>>=20
>> This has been tested together with the btrfs change, and it restores
>> correct functionality.
>
> I don't really like all this magic which is partially historic.  I think
> we should instead allow the fs to return any error from the export
> operations, and forbid returning NULL entirely.  Then the actualy caller
> (nfsd) can sort out which errors it wants to send over the wire.

I'm certainly open to that possibility.
But is the "actual caller":
  nfsd_set_fh_dentry(), or
  fh_verify() or
  the various callers of fh_verify() which might have different rules
  about which error codess are acceptable?

I could probably make an argument for having fh_verify() be careful
about error codes, but as exportfs_decode_fh() is a more public
interface, I think it is more important that it have well defined error
options.

Are there *any* errors that could sensibly be returned from
exportfs_decode_fh() other than
  -ESTALE (there is no such file), or
  -ENOMEM (there probably is a file, but I cannot allocate a dentry for
           it) or
  -EACCES (there is such a file, but it isn't "acceptable")

???

If there aren't, why should we let them through?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXo+L+AAoJEDnsnt1WYoG5eUcQAJhr0QWSnUGO6jfTV9GEDLCQ
L3o88zfgdZ1PIHfweEgARXp3RzhHRpesdiEkblV+i3THVzNgmbnehFTmJRyi+mCu
tC34fOPFxxa48Ab1sDEyWxPqldv+/yjJoyxWmcLEN+1qtBgWI3SnXYrcEtknAHfO
OQLRAWLZam65goPaDt8mhGR0masOizKCd066fB9KDRY2QbszhtFwzYaile3ASoIY
4gNkXZWo02MA0KFUFc+tVMOVbT1S5rvkAbAEQFaojYyOzRb6rcQ0lWIBdTn3SXka
NJ5fH1PVwlVNA87Q4Nsp7eFoc6/O9kUtQqAWLkc6IrEVUtW01KngXRh73rCYsJ8t
ijHH3nkFMC8uKsIJOzvfcwvj5nAwCWZwPq8jlGSfPdxtTmnaQDS8ewvgRbCRuQtg
1HnuM6Yujl4JIjqLmSxKnw8M0x43s2K5vx5Ud8xDceHIdQ1nka9lhK/pTSrC13tJ
z7RmGJsBn8ZdK/Tp3Qx4iD8i6PruahCx+CZP8bT5EMTjiRxq7SM56EDLyFB0ROj/
6vE0TFWdt/10CPqPMNbQY2cJdhuTXoBUCqCvh1h/hEoNcEmQK3c0a0faf0cqhDs7
WaitIE+Or0wh8tXSSi6lEDPKOWwH8eS2qdXJwe/pHdS86nV9H1F+apXfJGPlt11M
dM/rA9GPkgcrNE0tvrUW
=+e78
-----END PGP SIGNATURE-----
--=-=-=--
