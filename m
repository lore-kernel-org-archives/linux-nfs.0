Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46906 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751140AbdDJVme (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 17:42:34 -0400
From: NeilBrown <neilb@suse.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Tue, 11 Apr 2017 07:42:26 +1000
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: fix usage of mempools.
In-Reply-To: <586583e7-58d4-2386-aa71-f0a63ca93002@Netapp.com>
References: <87wpatvw6m.fsf@notabene.neil.brown.name> <586583e7-58d4-2386-aa71-f0a63ca93002@Netapp.com>
Message-ID: <87r310vt19.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 10 2017, Anna Schumaker wrote:

> Hi Neil,
>
> On 04/09/2017 10:22 PM, NeilBrown wrote:
>>=20
>> +		/* It is OK to do some reclaim, not no safe to wait
>> +		 * for anything to be returned to the pool.
>> +		 * mempool_alloc() cannot handle that particular combination,
>> +		 * so we need two separate attempts.
>> +		 */
>> +		p =3D mempool_alloc(nfs_commit_mempool, GFP_NOWAIT);
>> +		if (!p)
>> +			p =3D kmem_cache_alloc(nfs_cdata_cachep, GFP_NOIO |
>> +					     __GFP_NOWARN | __GFP_NORETRY);
>
> Do we need to add something to the nfs_commit_data structure to
> properly free a kmem_cache_alloc()-ed object?  Right now it looks like
> nfs_commit_free() calls mempool_free() unconditionally.=20

Good question.  I should have clarified that in the patch comment.
Can you add this to that comment please.

  The objects returned by kmem_cache_alloc() will still be freed
  by mempool_free().  This is safe as mempool_alloc() uses
  exactly the same function to allocate objects (since the mempool
  was created with mempool_create_slab_pool()).  The object returned
  by mempool_alloc() and kmem_cache_alloc() are indistinguishable
  so mempool_free() will handle both identically, either adding to the
  pool or calling kmem_cache_free().


Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIyBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljr/EIACgkQOeye3VZi
gbnfeg/2PC1/LNn67lY79n2u60emKbrcrVsjdQZbrr5X0B1zkPHJ2UzpnVLJJpN4
nwUeYdg2IWhm5zxeHUnwr/7/pM3MPq5piQ91jJPJ61T+vRA/MOD8/dq3zfd6Bk9a
ewzQJHZaBs2VHYuI7TVwW58XaenrglkKa9dXgTlfNyUa4CUptxFlAROVNYaPnQZu
V4wvkmf761uX2Db6yLBTdSlIQ26fEpQhGepsG/qN+/2pdAYEqYfUm+U7kY2vaq2y
FSzdeIxHXFHd5v6bkCp8VIGiIbTYeXfIhLbeY6noGSDLux8xEjx3Mtmwz4gnPIC0
jAsuLJUkH8hN8h51ddJHnmailNsgqMF1IACFtCnK2gNS555B45I4Q6ChvypfCPSl
Sw5QPU0qG9PaWcOWg9dve7hdthUCdpf6wFw7AMEm1uwup9DadUXg8i1wj3S5SwhY
sBb6lPCJUU91iezDoByOmO4iUtilIem07Ddxdlaar238J2MwvKhhOMJE8v7+m/kE
G8KOxAcCIUctCBxYf8Pitx8sOeqHtXJ42AGrANqzrvLpSJ721GbxyN3lthyeqhYG
4JGwHMd/FNtVUyAjMoOufvVvq8ckg0bU/2/3WcNGPikaaDII5i++NtPQ+Qpx+J6V
cUSfTbukvpDQyRCfW4BExjANlpsxuR/oeQKrHyvbXdgxdVl86Q==
=On0i
-----END PGP SIGNATURE-----
--=-=-=--
