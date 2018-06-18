Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58189 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753569AbeFREWt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Jun 2018 00:22:49 -0400
From: NeilBrown <neilb@suse.com>
To: paulmck@linux.vnet.ibm.com
Date: Mon, 18 Jun 2018 14:22:40 +1000
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        trondmy@hammerspace.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] rculist: improve documentation for list_for_each_entry_from_rcu()
In-Reply-To: <20180613100607.GH3593@linux.vnet.ibm.com>
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com> <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com> <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com> <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com> <20180613010427.GD3593@linux.vnet.ibm.com> <CA+55aFyWS-MC44k=LnGWr-Kq4_DRkJmub00Fj-tVrGxCL-PxGA@mail.gmail.com> <20180613013914.GE3593@linux.vnet.ibm.com> <87muvzihr8.fsf@notabene.neil.brown.name> <20180613100607.GH3593@linux.vnet.ibm.com>
Message-ID: <874li0g1v3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Unfortunately the patch for adding list_for_each_entry_from_rcu()
wasn't the final patch after all review.  It is functionally
correct but the documentation was incomplete.

This patch adds this missing documentation which includes an update to
the documentation for list_for_each_entry_continue_rcu() to match the
documentation for the new list_for_each_entry_from_rcu(), and adds
list_for_each_entry_from_rcu() and the already existing
hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/RCU/whatisRCU.txt |  2 ++
 include/linux/rculist.h         | 19 ++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.=
txt
index 65eb856526b7..d43524493fb3 100644
=2D-- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -816,11 +816,13 @@ RCU list traversal:
 	list_next_rcu
 	list_for_each_entry_rcu
 	list_for_each_entry_continue_rcu
+	list_for_each_entry_from_rcu
 	hlist_first_rcu
 	hlist_next_rcu
 	hlist_pprev_rcu
 	hlist_for_each_entry_rcu
 	hlist_for_each_entry_rcu_bh
+	hlist_for_each_entry_from_rcu
 	hlist_for_each_entry_continue_rcu
 	hlist_for_each_entry_continue_rcu_bh
 	hlist_nulls_first_rcu
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 36df6ccbc874..4786c2235b98 100644
=2D-- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -396,7 +396,16 @@ static inline void list_splice_tail_init_rcu(struct li=
st_head *list,
  * @member:	the name of the list_head within the struct.
  *
  * Continue to iterate over list of given type, continuing after
=2D * the current position.
+ * the current position which must have been in the list when the RCU read
+ * lock was taken.
+ * This would typically require either that you obtained the node from a
+ * previous walk of the list in the same RCU read-side critical section, or
+ * that you held some sort of non-RCU reference (such as a reference count)
+ * to keep the node alive *and* in the list.
+ *
+ * This iterator is similar to list_for_each_entry_from_rcu() except
+ * this starts after the given position and that one starts at the given
+ * position.
  */
 #define list_for_each_entry_continue_rcu(pos, head, member) 		\
 	for (pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member); \
@@ -411,6 +420,14 @@ static inline void list_splice_tail_init_rcu(struct li=
st_head *list,
  *
  * Iterate over the tail of a list starting from a given position,
  * which must have been in the list when the RCU read lock was taken.
+ * This would typically require either that you obtained the node from a
+ * previous walk of the list in the same RCU read-side critical section, or
+ * that you held some sort of non-RCU reference (such as a reference count)
+ * to keep the node alive *and* in the list.
+ *
+ * This iterator is similar to list_for_each_entry_continue_rcu() except
+ * this starts from the given position and that one starts from the positi=
on
+ * after the given position.
  */
 #define list_for_each_entry_from_rcu(pos, head, member)			\
 	for (; &(pos)->member !=3D (head);					\
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlsnM5AACgkQOeye3VZi
gbmEsQ/+MSPCAMzBIMqVEHJKY0GyWBgmBMOg0Rv+BMTSM3rN67iuafzsYH1cEbsB
O+c7RvtgDUdWxYfLAhNs1w+PlgmTruV48+pnfbLx1zR+O3sjir3Pm82u6VZigeNt
icv+kOBWH0fLQZaRvmTvzLCy9TpwBJ937iDPW0Rl0rNlbAFPBBRTf2WnovaTKRk3
yNM6FfVj6SjGFXnfBv7JtKMLhFhL9gJ5q+kf0ygyOKZtcSkPTSa+EkSaEJ/AAaIT
h50P6xrUtY1yRvvXbwKb/LqNq3XpJXkCfmAh++EUW7AreauyJokP4RHbVg92t0MG
s7xMt0taFjqakJt/892c8fiw/85M3Ln4I4ztI34FDmAo2RXTeqjwtXasEQ+85FDs
8ic2GIHxXBfEgPkROwC6tfEDHSQyU5M3Kwb37XTJYnEKsIa+F4mNJQWfQkdC8JKw
OtZhalvmuZvmjQsst2xyM4LiZzJvP3UApo2N9ZQu1pmCvzqW/9cfNQgFyv/+4ZtZ
ngWqDEQ3yaDw9czMaGasuRyJefKxYXjLTSBjmSy0XpuXwlUQFMB8Brm3C4AvpGV0
q6P3hmbYJH1y77TCA6XaR9KR745XigNutgMSlM6K6bsQIdcZMWSPF7AKZCmtKxRO
oWHK0EeZyNsiV7NybSr+9rzUlL1JNl861837LqSwAzrcqFKjgeM=
=A31H
-----END PGP SIGNATURE-----
--=-=-=--
