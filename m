Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49603 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbcLEEKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 4 Dec 2016 23:10:21 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 05 Dec 2016 15:10:11 +1100
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
Message-ID: <87oa0r584c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


There are two problems with refcounting of auth_gss messages.

First, the reference on the pipe->pipe list (taken by a call
to rpc_queue_upcall()) is not counted.  It seems to be
assumed that a message in pipe->pipe will always also be in
pipe->in_downcall, where it is correctly reference counted.

However there is no guaranty of this.  I have a report of a
NULL dereferences in rpc_pipe_read() which suggests a msg
that has been freed is still on the pipe->pipe list.

One way I imagine this might happen is:
=2D message is queued for uid=3DU and auth->service=3DS1
=2D rpc.gssd reads this message and starts processing.
  This removes the message from pipe->pipe
=2D message is queued for uid=3DU and auth->service=3DS2
=2D rpc.gssd replies to the first message. gss_pipe_downcall()
  calls __gss_find_upcall(pipe, U, NULL) and it finds the
  *second* message, as new messages are placed at the head
  of ->in_downcall, and the service type is not checked.
=2D This second message is removed from ->in_downcall and freed
  by gss_release_msg() (even though it is still on pipe->pipe)
=2D rpc.gssd tries to read another message, and dereferences a pointer
  to this message that has just been freed.

I fix this by incrementing the reference count before calling
rpc_queue_upcall(), and decrementing it if that fails, or normally in
gss_pipe_destroy_msg().

It seems strange that the reply doesn't target the message more
precisely, but I don't know all the details.  In any case, I think the
reference counting irregularity became a measureable bug when the
extra arg was added to __gss_find_upcall(), hence the Fixes: line
below.

The second problem is that if rpc_queue_upcall() fails, the new
message is not freed. gss_alloc_msg() set the ->count to 1,
gss_add_msg() increments this to 2, gss_unhash_msg() decrements to 1,
then the pointer is discarded so the memory never gets freed.

Fixes: 9130b8dbc6ac ("SUNRPC: allow for upcalls for same uid but different =
gss service")
Cc: stable@vger.kernel.org
Link: https://bugzilla.opensuse.org/show_bug.cgi?id=3D1011250
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/auth_gss/auth_gss.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3dfd769dc5b5..16cea00c959b 100644
=2D-- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -541,9 +541,13 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc=
_cred *cred)
 		return gss_new;
 	gss_msg =3D gss_add_msg(gss_new);
 	if (gss_msg =3D=3D gss_new) {
=2D		int res =3D rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
+		int res;
+		atomic_inc(&gss_msg->count);
+		res =3D rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
 		if (res) {
 			gss_unhash_msg(gss_new);
+			atomic_dec(&gss_msg->count);
+			gss_release_msg(gss_new);
 			gss_msg =3D ERR_PTR(res);
 		}
 	} else
@@ -836,6 +840,7 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 			warn_gssd();
 		gss_release_msg(gss_msg);
 	}
+	gss_release_msg(gss_msg);
 }
=20
 static void gss_pipe_dentry_destroy(struct dentry *dir,
=2D-=20
2.10.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhE6KMACgkQOeye3VZi
gbkCkg//Q0hVPJ4L8Z2w9P41u1hYNk0yGfbbZpR1kR5V/Jvt7ndi4CeZE9nyoCGH
xeyY7i9XBir6f8k2DSMeuyLvnEre2rj84EvaZ5lonwbk5RpDQ+ctQc3uGu5egogO
iC8fry0Bz9xefXJlvBZmnVOI5PkQTMRHIyP6XE8l3693GFik6ZVe0VYaocbzzJGO
cXG8ekX0xGgxhuEvkB6j7UhUVUri10P4izChRAw1EzlXSlpw7SfC6Arwu/AOqMMR
NTFwOrarTnAhlFdxS5FFzcRkWhM1sxgT4ik35IGt68jakcz/RG6MxB7Qu4FMVMCT
Rocl3rCvNgL1+hC5rIoqm9BcMpNxcVmEuwRQPNkH7hGIbRwURKY6Z1ceLGiT6eDT
Ty3PvIEWHbyrkHwe43+yWGWQZrhL6roCEy7DRVNSnyk2fzTZK/jE078zsbYkVcbF
ICbzov4qwG+oTpRbrLfsDhZJlSuPPaPDhbrG7y4xlkeeoWp4fnFyZMr8e/yFgL2H
dna4RDT44pU/5W+pb6Y8TD58/DAZifL6fqiSdoU/q5NChBPmUAPBamxO++MOOw8m
3LBMvk/0kbp8rfzpEJGjnhiRNQ6Hpr4gwJ4+24B1ccBqMN9aufsp/xOowUS6JCKr
F0syQEHdA0EZiN6ohFHx/BFyq6uo7sqjK5+Qt4oXOMDzbZV/i7E=
=gSN+
-----END PGP SIGNATURE-----
--=-=-=--
