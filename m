Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57103 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932237AbeBTARL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 19:17:11 -0500
From: NeilBrown <neilb@suse.com>
To: kbuild test robot <lkp@intel.com>
Date: Tue, 20 Feb 2018 11:17:03 +1100
Cc: kbuild-all@01.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 19/23] NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.
In-Reply-To: <201802192252.Y6fdV4Fk%fengguang.wu@intel.com>
References: <151901654943.17421.16135174786512989263.stgit@noble> <201802192252.Y6fdV4Fk%fengguang.wu@intel.com>
Message-ID: <87woz8jz0g.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Feb 19 2018, kbuild test robot wrote:

> Hi NeilBrown,
>
> Thank you for the patch! Perhaps something to improve:
>
> [auto build test WARNING on nfs/linux-next]
> [also build test WARNING on v4.16-rc2 next-20180219]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/NeilBrown/Remove-generic-rpc-credentials-and-associated-changed-V3/20180219-190836
> base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
>
>
> sparse warnings: (new ones prefixed by >>)
>
>>> fs/nfs/flexfilelayout/flexfilelayout.c:517:40: sparse: incorrect type in initializer (different address spaces) @@ expected struct cred const @@ got cred const @@
>    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: expected struct cred const
>    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: got struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred

Hi Mr Robot :-)
 It looks like you have some strange wild-card expansion happening here.
 I think the above should be
>    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: got struct cred const * cred

Even after correcting the that, I cannot see what the different address
spaces are that might be a problem.
Does anyone have any ideas?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqLaP8ACgkQOeye3VZi
gbm21RAAuy/Kg9ehBKeh1b1aGF37tV20F3Gp9zgLQnvocO83vfk3lV/WNJPvGaK/
C2JDiVahqhnjTimLVbZfQLVi+Jq28iUtSQCkb0nHErGEub1oaWmbrXRwHz8SpiL4
sF2WLAlHMtkHpOHXzCVpgz7TMF09F66rIEsilWhKV8U4yPFeda9j8fPbcuPuJOrc
Pc0ahQ4D0+p0dgsm0AVTxwrbnl4FxjOmeBtyyca6frjleNM+juOXlTcIvzNNTTiz
PbxbAkyaQkZKLrL7SMvyllgNQz2sR7kMB777cm2dP/pZ37A4N1URfRCVYsM9ilHu
ywqJgNsFaxYe36MnhanE8/UQ3MaO3wwDXfMqUQuP93kzlfIq7ULnnc+vK3JFQH3l
Q1fF04FPFOS3No6/xsbQ//lwG+HC1EvRZJRsY1iT00blDauUmQGMal7gc9m0xzTL
MV7WH2yy1ncPcv4eJzKPIOckOL4qiURTzeo4YHuVDRMCpKkCZHSJSHRYqZHQ3sOs
ZkBOY1v+HBDiSm06pHdMHROtbVyYUTZydxkIJCPBioDZ9mrzar43zCoxnS0+uAaT
hIb78pDArgcLZSQSOGzxUNy4X2UXS8DELVL6iy3vM5ydbda3xPsE68yPLLIkF9Nu
ZT+AQWln1PLu3YpAWPW1Jr9S6RvIOKMeVaiu0r0O3d0mPfjzS/g=
=f1Nb
-----END PGP SIGNATURE-----
--=-=-=--
