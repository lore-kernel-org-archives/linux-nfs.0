Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48760 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756255AbdCGXb4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Mar 2017 18:31:56 -0500
From: NeilBrown <neilb@suse.com>
To: gss-proxy@lists.fedorahosted.org,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 08 Mar 2017 10:14:01 +1100
Subject: migration from svcgssd to gssproxy results in regression.
Message-ID: <87lgsgissm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi,
 I recently tried using gssproxy for krb5 authentication with nfsd.
 This was because customer is using an AD kerberos master which uses
 certificates which are too big for svcgssd to work with (i.e. larger
 than one page).

 Unfortunately it doesn't work.

 The svcgssd code in nfs-utils calls
   gss_display_name()
 to get the name of the principal.  This returns something like
 "user@domain".

 getpwnam() works perfectly on this (when nsswitch is set to use "winbind")
 but svcgssd goes further and uses nfs4_gss_princ_to_ids() to perform
 the lookup.  Presumably this is more general?

 gssproxy does neither of these.
 It uses gss_localname() to get the user name, which returns something
 like "user".
 It then calls getpwnam() on that, which fails ("user@domain" or
 "domain\user" both succeed).

 I have modified my copy to use gss_display_name() instead of
 gss_localname() and it now appears to work perfectly ... for this
 use-case at least.

 What is the right way forward here?
 Is nfs4_gss_princ_to_ids() really necessary?
 Should gssproxy use it, at least for requests from the NFS server?
 Is there are good reason not to use gss_display_name() uniformly?
 Maybe use gss_local_name(), and it that fails, or getpwnam fails,
 use gss_display_name()??

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli/PrkACgkQOeye3VZi
gblmChAAhr43eGvc/AdyitFOGI29pXLHV3uYivGDsFtHEXFcNXKUJPLFyHcb4n17
9ljcpnGdH46tEHIgMg+qYJzw+/MwTC5MoBvBj96Q7Daz+yWCNDHxAn6Dt8SbvPa2
81Babgcug6McNY74/PQuYbK9UsZTW9602qKkgdT3F+SBoMpqJeqM3nMRr74HafIU
ZKFVfK4ZogWIvFiHjLgWkEJDvVKgStltYwzJ6e2p8CM1GYYgDzCv4aIjPZxIYH+B
nWXD3eJ8k3vKiAlTUW6bomv1L5IxBkJXkItmx6yH23fJAs/cuyI/PVEabm7EDHA5
QMRkHhIk6by4HbZJSMoJvn4BALENtKlAEIVT7y6k1jpAxXtg0/5/7jo+ANgveaSO
VVRnLdaBv48kKDUFyAZFJ/kMzAiwPFJCgP2Lb45Iv5NITur8yETdCu/Yu/7unIo9
1JT0nHvV7azIwxDi5RzH3ef1F2I9Nc4xxI/MkHOzu4SBlk3lIVkVjGqSsXOem44a
MQThIZRXqQDLKBwgNwLEnRNNX9LhKKJWzXMN1fWS6K0J7rf9/U/qmY7dEoW2/lEQ
xUF+tiIpLl09Vw4DF0pO74ywApLsmk69i6Ppx4LvP4ve5Zrq6mRY5ykUK2XVFFMk
tDv/Ln/6YQpgKORT1fAuqkVAjKCj7Z4vPiVCNNQT0IgYhpe3hXI=
=h2cP
-----END PGP SIGNATURE-----
--=-=-=--
