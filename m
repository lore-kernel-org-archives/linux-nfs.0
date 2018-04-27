Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54783 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751291AbeD0F3Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Apr 2018 01:29:16 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 27 Apr 2018 15:29:03 +1000
Cc: Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: Avoid quadratic search when freeing delegations.
Message-ID: <87h8nxkyjk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If an NFS client has 10,000 delegations which are between 90 and 180 second=
s old,
and 10,000 which are between 180 and 270 seconds old, with none of them sti=
ll
in use, it is likely that the old ones are at the end of the list.
The first 10,000 will not be marked to be returned, the last 10,000 will.

To return these, the code starts at the front of the list and finds the
first delegation needing to be returned (testing 10,000 on the way).
Then it drops rcu_readlock(), returns the delegation and starts again,
and does this 10,000 times.

As delegation return is async, it may never block, so these 10,000
delegation will be returned without stopping for a breath.  The soft-lock
detector will notice and complain.

This patch makes 3 changes.

1/ cond_resched() is added so that the soft-lockup detector doesn't notice.
2/ A place-holder (an inode) is kept when locks are dropped, so that
   the place can usually be found again after taking rcu_readlock().
   This means we don't need to skip over 10,000 entries 10,000 times,
   100 million pointless operations - which could eaisly be a larger
   number.
3/ If nfs_sb_active() fails, break out of the loop - there is no point
   in continuing.

The patch also add list_for_each_entry_from_rcu() to rculist.h in
order to achieve 2/.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi,
 I'm hoping one of the RCU reviewers will provide an Acked-by for the
 rculist.h change.

 If you'ld like 3 patches instead of just one, please let me know.  But
 they all see to fit well together.

thanks,
NeilBrown


 fs/nfs/delegation.c     | 57 ++++++++++++++++++++++++++++++++++++++++++++-=
----
 include/linux/rculist.h | 10 +++++++++
 2 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 1819d0d0ba4b..c3d9e21ab440 100644
=2D-- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -483,19 +483,56 @@ static bool nfs_delegation_need_return(struct nfs_del=
egation *delegation)
 int nfs_client_return_marked_delegations(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
+	struct nfs_delegation *prev;
 	struct nfs_server *server;
 	struct inode *inode;
+	struct inode *place_holder =3D NULL;
 	int err =3D 0;
=20
 restart:
+	/*
+	 * To avoid quadratic looping we hold an reference
+	 * to an inode place_holder.  Each time we restart, we
+	 * list nfs_servers from the server of that inode, and
+	 * delegation in the server from the delegations of that
+	 * inode.
+	 * prev is an RCU-protected pointer to a delegation which
+	 * wasn't marked for return and might be a good choice for
+	 * the next place_holder.
+	 */
 	rcu_read_lock();
=2D	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
=2D		list_for_each_entry_rcu(delegation, &server->delegations,
=2D								super_list) {
=2D			if (!nfs_delegation_need_return(delegation))
+	prev =3D NULL;
+	if (place_holder)
+		server =3D NFS_SERVER(place_holder);
+	else
+		server =3D list_entry_rcu(clp->cl_superblocks.next,
+					struct nfs_server, client_link);
+	list_for_each_entry_from_rcu(server, &clp->cl_superblocks, client_link) {
+		delegation =3D NULL;
+		if (place_holder && server =3D=3D NFS_SERVER(place_holder))
+			delegation =3D rcu_dereference(NFS_I(place_holder)->delegation);
+		if (!delegation)
+			delegation =3D list_entry_rcu(server->delegations.next,
+						    struct nfs_delegation, super_list);
+		list_for_each_entry_from_rcu(delegation, &server->delegations, super_lis=
t) {
+			struct inode *to_put =3D NULL;
+
+			if (!nfs_delegation_need_return(delegation)) {
+				prev =3D delegation;
 				continue;
+			}
 			if (!nfs_sb_active(server->super))
=2D				continue;
+				break;
+
+			if (prev) {
+				struct inode *tmp;
+				tmp =3D nfs_delegation_grab_inode(prev);
+				if (tmp) {
+					to_put =3D place_holder;
+					place_holder =3D tmp;
+				}
+			}
+
 			inode =3D nfs_delegation_grab_inode(delegation);
 			if (inode =3D=3D NULL) {
 				rcu_read_unlock();
@@ -505,16 +542,26 @@ int nfs_client_return_marked_delegations(struct nfs_c=
lient *clp)
 			delegation =3D nfs_start_delegation_return_locked(NFS_I(inode));
 			rcu_read_unlock();
=20
+			if (to_put) {
+				iput(to_put);
+				to_put =3D NULL;
+			}
+
 			err =3D nfs_end_delegation_return(inode, delegation, 0);
 			iput(inode);
 			nfs_sb_deactive(server->super);
+			cond_resched();
 			if (!err)
 				goto restart;
 			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+			if (place_holder)
+				iput(place_holder);
 			return err;
 		}
 	}
 	rcu_read_unlock();
+	if (place_holder)
+		iput(place_holder);
 	return 0;
 }
=20
diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 127f534fec94..2d86f9869842 100644
=2D-- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -403,6 +403,16 @@ static inline void list_splice_tail_init_rcu(struct li=
st_head *list,
 	     &pos->member !=3D (head);	\
 	     pos =3D list_entry_rcu(pos->member.next, typeof(*pos), member))
=20
+/**
+ * list_for_each_entry_from_rcu - iterate over a list continuing from curr=
ent point
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_node within the struct.
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlritSAACgkQOeye3VZi
gbmVABAAuQllng/FqKKiGmVgo765puwDfSvOOxjDHM34NsJBv7JRN3m8xbQL7YOs
UUPJ0T1SA2u+JfWI3mu1Jule5azvaknS6Kek59m+Rw5/LrjiRhDr4s+uyIBg2OHJ
fyGrmvjitM7OQ1aocPIPTuP4H1GJ45ZEEuASX+tlzKgELI9J0I8/f/3ywIEQ2ESl
XIOWk54dU52xl/mgh9abRN0+FCgIhZbZGjzlZDKH/NXDgU6Ja/7zJcrib2RA0pvb
WHgbjmB25P6DW5EbHZQasd/WjpK4TC+9h1jhYp/D8adLxOZm2V/CTqlBphzrg2hm
2qfV9AqX6238HaY05w1uvEIbIL/jIMDUL6TbU1Byo41lubzhFg1ffJ5MgkXOfOgU
2HiY2pQJgkk3UCEHgyMeSPGN8IytNfPC839VG8PIL1wZ6Q+HCv1muyJai9TKkhY0
FDHB7z476J6XiYZ3JbBbm0D0tJSl4Y8GnMHWK4fGckkqGOUQHqy56fo7ccv1vbhK
9LQYqH6ewJfffRbhyH+hOo6+BAX5zeAyRmS6c7B2FPTTDAcJEVE4kc1IyYxXPlVo
tSyMfJWU68JBC0PYIPaQDglZ6LK1odSkLzPG4N+dN6rkswfQ4xhCoMBdI80fTKjB
lGQSb6fcFbqGRLPeO6gYtHTsRD7xSBiLin5gyJOvdwC1636C6C4=
=/YRi
-----END PGP SIGNATURE-----
--=-=-=--
