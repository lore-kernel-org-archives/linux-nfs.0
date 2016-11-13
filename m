Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33568 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935048AbcKMXJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 13 Nov 2016 18:09:58 -0500
From: NeilBrown <neilb@suse.com>
To: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 14 Nov 2016 10:09:50 +1100
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to /run/rpcbind
In-Reply-To: <20161111210034.GM21655@vapier.lan>
References: <877f8almcf.fsf@notabene.neil.brown.name> <20161111210034.GM21655@vapier.lan>
Message-ID: <87polzj7sx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 12 2016, Mike Frysinger wrote:

> [ Unknown signature status ]
> On 11 Nov 2016 14:36, NeilBrown wrote:
>> rpcbind can save state in a file to allow restart without forgetting
>> about running services.
>>=20
>> The default location is currently "/tmp" which is an over-used
>> directory that isn't really suitable for system files.
>> The modern preferences would be a subdirectory of "/run", which can
>> be selected with a ./configure option.  That subdirectory would still ne=
ed
>> to be created by something.
>
> the portable path is /var/cache instead of /run.  i don't think libtirpc
> should be configuring itself to assume Linux by default.

In principle I agree.  But is /var/cache really a good choice?
We don't want the state files to persist over a reboot, and I strongly
suspect that /var/cache is designed to do exactly that.

Are there agree standards that are broader than Linux that we can look
to?
FHS defines /var/run (or even /run) but I suspect it is linux-only.

https://en.wikipedia.org/wiki/Unix_filesystem#Conventional_directory_layout

only suggests /tmp as something that won't survive reboot.
Maybe we should continue to use the /tmp filesystem, but move to a
subdirectory:
 /tmp/rpcbind
??

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKPK+AAoJEDnsnt1WYoG5MlwP/RDW3wSMzNz0YQNvT7GQdpUS
f0EVKsdn24nKVArYSpo4sKOcjmhs03g0aYUWmu910QNT/ygQ0AuElmOrdDjJTnuc
uioo7/fC3Gf790g10zJMxsGs48YNau0YxRV+V2B4roubzgpYS9tQC53xdRFX98tA
UBcRpmE/y/X50Lf35UWHyW9Rn3mROHMUXXAy7bo1wJ7+LdOrC9ANu0F0ufq60MnC
Otm1AZ3Qk4Wt2ybB4I2v8gjtCzf0f3du5FfXKn1QA90/kSCeQ9qhqlNmv4CwwoWf
4tyhkcMLiETiCf1rNNZeJ/67ewG6By3hjE8pSggf4yr1ndtKSpdCmtiOHDsHQUN3
dYOzTcTmc7gg+sjgxrxjg2VT0iOgoo76PpKyNeXJVTj/DRyvSSOusXiUc6eEK39D
aj++9z2iH3cy6UNdo+TaLRJTnQ0jhbcfdJwJMmzwiGw+ZA59u6zu58Qfbi84Pnp3
J+pyP/zbHLnwS+hgYqSrPH4OugJY2LOhz5Ny52ODnBfBAAoL7YmQqYuDb8YD6AbV
/gRAMRshceaDXMn/fl7tfF/vsIR7+b8/wc95HYow43nEbwz3Rqvaqa6shVzUqnhz
GyDQ8pbTfUCRFlwXRAcJ5/pLfpYcDic2nkY6/S2OozfnvvT+4jg0y4Vf6ivD8jBZ
meVDM/fDtW8sZbcXYIUY
=zk3b
-----END PGP SIGNATURE-----
--=-=-=--
