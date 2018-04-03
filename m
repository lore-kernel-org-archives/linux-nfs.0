Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41774 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754550AbeDCAmG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Apr 2018 20:42:06 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 03 Apr 2018 10:41:56 +1000
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
In-Reply-To: <20180320214821.GF4288@fieldses.org>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name> <878tasc3ag.fsf@notabene.neil.brown.name> <20180320214821.GF4288@fieldses.org>
Message-ID: <87bmf115pn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 20 2018, J. Bruce Fields wrote:

> On Fri, Mar 16, 2018 at 10:44:23AM +1100, NeilBrown wrote:
>>=20
>> nfs4_proc_exchange_id() can return -EINVAL if the server
>> reported NFS4INVAL (which I have seen in a packet trace),
>
> Can you say which server this was?  (One we can fix?)

It was Linux 2.6.32 (on armv5), and presumably anything before
Commit: 357f54d6b382 ("NFS fix the setting of exchange id flag")
which landed in 2.6.38.

These servers return NFS4ERR_INVAL when EXCHGID4_FLAG_BIND_PRINC_STATEID
is set in the exchange_id flags, which Linux has done since
Commit: 4f0b429df104 ("NFSv4.1: Enable state protection")
in 3.11.

Maybe NFS should retry without that flag if it gets EINVAL??  Or it could
just say that NFSv4.1 isn't supported.  I still don't think EIO is justifie=
d.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlrCzdQACgkQOeye3VZi
gbnhmA//TKL02mWToXL1oF2lafOEt3viNUgCD7KiTGfcFu72uc9i3lXdR2jLY9Ic
A07myAzcYbBDivRUY3QUawcAxlDGepnG5yGAmhnzR9hF8DWPsFHVGbCVPzGE/csc
VC3v/TVs7spMmDtt8B1amKAwTxoFRBNHoL5KQRXlRbxWvFrIGjizwYEGiDTOsECj
gVjr+SyQ5c+Zhrdo7ErAflXaZRKLLjAmWIba1rItLCYXX+fd5XNJcmj2xzTF7Bf5
T9riHw9mUy+NXDBSrn2hJJp6x0vGzUJVwxtRW3/5Gg9WC3D7Ou7pr7Te+qi0QOMe
0u5v1ZwJeNutWpg63r9tMM8OMwIi+RwahPnvjiNeb7UQUDxeRTkhXqYHdazgNa0+
G+SFUR9S8olHQC/7t7e3FemCXo+ugCYMyWTLZqyv6QEHbp5gE0ozpWcRkAlwQdxQ
4+3Nv9S2JO/yiDzXjLVeqiuQ4zjC2YQzYTH2M8GArq20dCKLo/w8veRuZROoz3fg
XGVyKw4OnLpVtfXiRg/+Ual+RVgAL4RckT94ONIlwrBOLVcCqu/oBrvOqVOs/OYC
jQ4xxpSooRenIzhAEbcFG/1YR0VkUvjjpkmzMa78X+NcwecialijaZgsKRvEcsiQ
OI2wiBkobjFhnu8Lzd5ZA5bqi9+F6Thm54jOZojw4MhQCfiOmgg=
=Zhx3
-----END PGP SIGNATURE-----
--=-=-=--
