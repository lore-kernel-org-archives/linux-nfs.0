Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56838 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934873AbeFMBnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Jun 2018 21:43:04 -0400
From: NeilBrown <neilb@suse.com>
To: paulmck@linux.vnet.ibm.com,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 13 Jun 2018 11:42:51 +1000
Cc: trondmy@hammerspace.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
In-Reply-To: <20180613013914.GE3593@linux.vnet.ibm.com>
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com> <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com> <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com> <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com> <20180613010427.GD3593@linux.vnet.ibm.com> <CA+55aFyWS-MC44k=LnGWr-Kq4_DRkJmub00Fj-tVrGxCL-PxGA@mail.gmail.com> <20180613013914.GE3593@linux.vnet.ibm.com>
Message-ID: <87muvzihr8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 12 2018, Paul E. McKenney wrote:

> On Tue, Jun 12, 2018 at 06:11:50PM -0700, Linus Torvalds wrote:
>> On Tue, Jun 12, 2018 at 6:02 PM Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> >
>> > We did review this one, and Neil did make requested changes to the com=
ment
>> > header and documentation.
>>=20
>> Oh, I checked the commit for "acked-by" from you and didn't see any,
>> so I was assuming this was just Neil and Trond on their own..
>
> Hmmm...  I gave them a Reviewed-by, but perhaps it got lost.
>
> http://lkml.kernel.org/r/20180501141404.GD26088@linux.vnet.ibm.com
>
> 							Thanx, Paul

Sorry about that.  I think I planned to add it after I heard back from
Trond what he thought of the patch, but I didn't hear anything until it
landed.  I'll try to be more proactive next time.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlsgdpwACgkQOeye3VZi
gbndFw//TDdnzYb2pD6LMPDSdbugR/S6YG066IwkA04X1jnJaU8fTTbunnb8uOi+
QIIJ/lKgTBl1ixqVozgcvDS/MlX1sdaGdtUsEx7Ch24Za8w7xdsEKz1roLavT3gw
RCMDKoKbT3h2E5WtT6DDBLPfC23M6QQ0q83GSSWlRTzxVgQR+WyTwfdMMoXEM2Uu
SVRGlakNQ8H6C3YuJ+BoucdoIByHSkG0dZfCCFVq+NccN0sU+nKXjTdXeQsvXizP
LcU12B4abPuVtjz+4HusU8XQzVaLEJWUp/HveeOAwDknaphXaxvWxCGe/yc5az9J
Z3HqIJXEEOLMtA91SiZgfH48jeF4JCr74oPNfZN3dkegQSFegsjPF+9/Zbq6RLPI
9B/dEL6EZ96tnjGuq1hCFIY/c8BoRic9Omq87CKg4zO3Cjj28eGghEOgbNspqQ2Y
To/GUT7OY1wPI7LVbK8dg9bVsBCrQLL1P4aMELV8Kbue8pAC2YO2ei/5s/7nQKZc
crZgfwCCY98B8ClVH9sXYc5kPg79nW9BD1NFZfIqPKUQmp7vMq7eeVsC0T8E+qLF
3LU9PnFbhtpl5U6Dvgj+v71BHv/PYKLHe9iTqQV5E1WMYYpAHNkDJcWgr3H5RpwF
TqJpFbsU7cnO+XIEPj7DYWtz1ZpFyqtWjqHb6QtSD8ISAVvZyfM=
=SCwn
-----END PGP SIGNATURE-----
--=-=-=--
