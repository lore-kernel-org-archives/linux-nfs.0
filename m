Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51161 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750736AbeABVB2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Jan 2018 16:01:28 -0500
From: NeilBrown <neilb@suse.com>
To: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org
Date: Wed, 03 Jan 2018 08:01:15 +1100
Cc: dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        willy@infradead.org, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] Documentation: security/credentials.rst: explain need to sort
 group_list
In-Reply-To: <20742.1514904840@warthog.procyon.org.uk>
References: <878te9os81.fsf@notabene.neil.brown.name> <20171211142708.GA23284@bombadil.infradead.org> <20171211151420.18655-1-thiago.becker@gmail.com> <20742.1514904840@warthog.procyon.org.uk>
Message-ID: <87wp10dlgk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This patch updates the documentation with the observations that led
to commit bdcf0a423ea1 ("kernel: make groups_sort calling a
responsibility group_info allocators") and the new behaviour required.
Specifically that groups_sort() should be called on a new group_list
before set_groups() or set_current_groups() is called.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/security/credentials.rst | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/security/credentials.rst b/Documentation/securit=
y/credentials.rst
index 66a2e24939d8..5d659e3e52ad 100644
=2D-- a/Documentation/security/credentials.rst
+++ b/Documentation/security/credentials.rst
@@ -451,6 +451,13 @@ checks and hooks done.  Both the current and the propo=
sed sets of credentials
 are available for this purpose as current_cred() will return the current s=
et
 still at this point.
=20
+When replacing the group list, the new list must be sorted before it
+is added to the credential, as a binary search is used to test for
+membership.  In practice, this means ``groups_sort()`` should be
+called before ``set_groups()`` or ``set_current_groups()``.
+``groups_sort()`` must not be called on a ``struct group_list`` which
+is shared as it may permute elements as part of the sorting process
+even if the array is already sorted.
=20
 When the credential set is ready, it should be committed to the current pr=
ocess
 by calling::
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpL8xwACgkQOeye3VZi
gbk/XxAAvbx35+9dWh4R91oH8Xn8z0Ae70iJ6Sm5YWGWB0yv/NxVAEdo5F6wvI+l
a2oqPqdr3WvI22QVCCXknGyE3GNS8xAJXaFgo28sPSypIb4OQqhkmBb1RZOEmX8m
C3w3FLJNIoV/ml5xvFDrvAss9wL+A1Iv/aFiiD4POw8MzPTNyw5gT9/UHZ/+jC4o
LUBnYacLVN3iijL1MIDQ8iki6bwW9AFvdq14wbLXoNkkt6V3IzfBKfOxyFmnohgs
i/mX5I1LdlT+kgFihGxSRA7bEq51CXrOXZzl4XiAKBNBI5BQgKsZocn6W584URdm
q2yg94sYInR/V1enY+vxRF7rVHmHxnmM912aQK+5amASPkhwPPcenBeCsOwuZgPj
X2DajZcHRf0Z8+oP/yidAIIIE2ZhO4rtnZfBu2OwxlLpQax03xR21T9Exbns/+rn
2S2+nid0wCguUkWYwFa0pyIsJHQz3l/ZRDixwcq/OgwlG8giBVwXQkNR4nEbpuKs
gyh08t/o0wy6frhWhIJsKGjHs3BI6EqaYZ2UcoCI8WMDfaCAnZFiYPPOOcEkl6n7
E6Tg+MnJzGcqxuJU7LUVNzV3GmPFt07ggxm8+lWnrNmfKpx60E/nQJLaUv/jF6FP
HbqwKpoqa6ge2go5Xk2d8HMWMcXl2YoznpRAziWHrtJIbIgns/I=
=lb2j
-----END PGP SIGNATURE-----
--=-=-=--
