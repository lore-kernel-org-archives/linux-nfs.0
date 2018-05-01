Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56826 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751558AbeEADLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 23:11:45 -0400
From: NeilBrown <neilb@suse.com>
To: paulmck@linux.vnet.ibm.com, Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 01 May 2018 13:11:29 +1000
Cc: Josh Triplett <josh@joshtriplett.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        linux-kernel@vger.kernel.org
Subject: [PATCH 3/4 v2] rculist: add list_for_each_entry_from_rcu()
In-Reply-To: <20180430153505.GW26088@linux.vnet.ibm.com>
References: <152506256513.7246.13171564155614823841.stgit@noble> <152506269061.7246.13075216914692813995.stgit@noble> <20180430052032.GA16963@localhost> <20180430134308.GT26088@linux.vnet.ibm.com> <20180430111454.722c2aa8@gandalf.local.home> <20180430153505.GW26088@linux.vnet.ibm.com>
Message-ID: <87y3h4gjdq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


list_for_each_entry_from_rcu() is an RCU version of
list_for_each_entry_from().  It walks a linked list under rcu
protection, from a given start point.

It is similar to list_for_each_entry_continue_rcu() but starts *at*
the given position rather than *after* it.

Naturally, the start point must be known to be in the list.

Also update the documentation for list_for_each_entry_continue_rcu()
to match the documentation for the new list_for_each_entry_from_rcu(),
and add list_for_each_entry_from_rcu() and the already existing
hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 Documentation/RCU/whatisRCU.txt |  2 ++
 include/linux/rculist.h         | 32 +++++++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.=
txt
index a27fbfb0efb8..b7d38bd212d2 100644
=2D-- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -814,11 +814,13 @@ RCU list traversal:
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
index 127f534fec94..4786c2235b98 100644
=2D-- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -396,13 +396,43 @@ static inline void list_splice_tail_init_rcu(struct l=
ist_head *list,
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
 	     &pos->member !=3D (head);	\
 	     pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member))
=20
+/**
+ * list_for_each_entry_from_rcu - iterate over a list from current point
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_node within the struct.
+ *
+ * Iterate over the tail of a list starting from a given position,
+ * which must have been in the list when the RCU read lock was taken.
+ * This would typically require either that you obtained the node from a
+ * previous walk of the list in the same RCU read-side critical section, or
+ * that you held some sort of non-RCU reference (such as a reference count)
+ * to keep the node alive *and* in the list.
+ *
+ * This iterator is similar to list_for_each_entry_continue_rcu() except
+ * this starts from the given position and that one starts from the positi=
on
+ * after the given position.
+ */
+#define list_for_each_entry_from_rcu(pos, head, member)			\
+	for (; &(pos)->member !=3D (head);					\
+		pos =3D list_entry_rcu(pos->member.next, typeof(*(pos)), member))
+
 /**
  * hlist_del_rcu - deletes entry from hash list without re-initialization
  * @n: the element to delete from the hash list.
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlrn2uMACgkQOeye3VZi
gbl7bA//W3TjUzSU4+ja3D9oxTbNDhIv2f1bnpDn/vnltpEe4pHlc65X9ldm8Xyz
y4PmifQozWFUjYJwHyLasWgHGJrVD/Ij9bEv7bj94DJEOkF4S611XcLEM+Ke6R8t
rf9lYzJQINcdbJcgubC2FKa11aMmBn78pqUQPUSfYomo/kaDdyQaReUJ2p4cujr9
vewOHFdFp6nksvFLU7AAWgj77jyDQ40CVJC4RnS7c6V72I+kcK+r1+dWv2K05onA
4HZGA5Hr8mamdgAT4QCr2azG93Vyp3HROug50rszEpk4JnYex0nN1e9YH4d9/9zl
aHOK2RsS+hd/S8gkRcsgStMNVnyqE+DKIDBXdHejaTPtY6M9JrfrihFMhLhzrjhe
YqNFngoZ3l9D7F+cI6gmacGoiEKvLDrl7l9TDu2Np01p1eFc4tgG6qJ5nCV4ikcL
y/tw4OBK2/WVrkZbPPfd7pKmkzUzP/KKyd53PchQfpK/OhjOBVwSCE7hW1Lrs4iI
vyiuOaexLfYYaFhAvzTdJNd4wz0pxiEKN1U9e1v624Zys+mDMxQs7F+v+vf/WF7F
WaPDG60kvO16G6GGWMYAdePfXJ4xPyYKxzSelR56MvaByIDWiAh2Qr7f14RjZL3F
YeOnr7SOndaNM5/R6zsEshnbCM3tvFFuOAEHHyvIlfa7SRFtRow=
=UjZC
-----END PGP SIGNATURE-----
--=-=-=--
