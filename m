Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60530 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754589AbcJKWdp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Oct 2016 18:33:45 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Wed, 12 Oct 2016 09:14:20 +1100
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID
In-Reply-To: <C37BA8D0-2EAF-41D7-9086-D8729D4BAD48@primarydata.com>
References: <87y46monel.fsf@notabene.neil.brown.name> <87bmyx3q3u.fsf@notabene.neil.brown.name> <C37BA8D0-2EAF-41D7-9086-D8729D4BAD48@primarydata.com>
Message-ID: <8737k2354z.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, Oct 08 2016, Trond Myklebust wrote:

>> +	set_bit(NFS_OWNER_STALE, &sp->so_flags);
>> +	/* Delegation recall might insist on using this open_owner
>> +	 * so reset it to force a new 'confirm' stage to be initiated.
>> +	 */
>> +	sp->so_seqid.create_time =3D ktime_get();
>
> Hmm=E2=80=A6. If you=E2=80=99re going to do this, then why mark the state=
_owner as stale at all? Why not just reset sp->so_seqid.flags and call nfs4=
_clear_open_state() to let the state recovery try to do what it can.

Good point ... I was too focused on how I got there and what I had
tested...

I cannot test this properly as I don't have a server that returned
BAD_SEQID, and I doubt I can convince the customer to test some new as
they have something that works, but I think this is correct.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Fri, 3 Jun 2016 14:58:02 +1000
Subject: [PATCH] NFS: Don't disconnect open-owner on NFS4ERR_BAD_SEQID

When an NFS4ERR_BAD_SEQID is received the open-owner is removed from
the ->state_owners rbtree so that it will no longer be used.

If any stateids attached to this open-owner are still in use, and if a
request using one gets an NFS4ERR_BAD_STATEID reply, this can for bad.

The state is marked as needing recovery and the nfs4_state_manager()
is scheduled to clean up.  nfs4_state_manager() finds states to be
recovered by walking the state_owners rbtree.  As the open-owner is
not in the rbtree, the bad state is not found so nfs4_state_manager()
completes having done nothing.  The request is then retried, with a
predicatable result (indefinite retries).

If the stateid is for a delegation, this open_owner will be used
to open files when the delegation is returned.  For that to work,
a new open-owner needs to be presented to the server.

This patch changes NFS4ERR_BAD_SEQID handling to leave the open-owner
in the rbtree but updates the 'create_time' so it looks like a new
open-owner.  With this the indefinite retries no longer happen.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4state.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 74cc32490c7a..c4d721ed493d 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -496,19 +496,10 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
=2D	struct rb_node *rb_node =3D &sp->so_server_node;
=2D
=2D	if (!RB_EMPTY_NODE(rb_node)) {
=2D		struct nfs_server *server =3D sp->so_server;
=2D		struct nfs_client *clp =3D server->nfs_client;
=2D
=2D		spin_lock(&clp->cl_lock);
=2D		if (!RB_EMPTY_NODE(rb_node)) {
=2D			rb_erase(rb_node, &server->state_owners);
=2D			RB_CLEAR_NODE(rb_node);
=2D		}
=2D		spin_unlock(&clp->cl_lock);
=2D	}
+	/* Delegation recall might insist on using this open_owner
+	 * so reset it to force a new 'confirm' stage to be initiated.
+	 */
+	sp->so_seqid.create_time =3D ktime_get();
 }
=20
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/WQ8AAoJEDnsnt1WYoG50IIP/Rn4524MJzu33fROeHIMrZIx
EK6Fi7lN5yR+7FdK9KbEkMDjNnh+iXgtkP1yvbqZaPuavxGAiEwrNRGNHBuaO91D
AXz79OsTkU3ha3mMbQoLubg/8Gaz7hhZ9+2Ee2ZZeE7DkPgzDZtEoOAO0MY9+mwt
i+/D8HS3wtq/2+N9A9BJywtCKr7liGQuVvEab/PgoZ5Rfo0RvJUxR+RcC3anbJ6t
iVRh618qoXT4zlplAQepdJNiii9BBxeWoHVMOsHRPgCU/M5IAzEo9Od4YTHXFtwx
CJ4aa4RHUD3TwR+ONg88eH/ChD5mJfNGzoNvsewkAzNKzdqyKFjddJBQu/O9wLv0
j0yFcMQ06rbPsEKmlil18d3KQmYINrN/sRJYJm+Vy0J6kdnl8+aJpD2wWKOqSi2c
9n6oooholZ8b/do8Ar1Co1OtmWfSI1o/fzSfiY+Q4mNVxSRJUbP2m02VEfah8+ki
vXcF6pWjDTBddAHKhd76hGgvMwywRCGfJrR6aMQ54uEd1ul0bRbY4LuErPdWz3JQ
IDT95LUTKCzdh6QDT/rtWrfa24mQjzW9l4GrDcbmgDgb6cNxvYAUSX6eQmQzZEIn
NamO/0FNOxosUjqEPDxWvr9ShA6krVrGxeyVRybSDhCB23k8I/HhmqRE/L13iQ5B
/o+CIYuFkdowXcXymq2G
=dngX
-----END PGP SIGNATURE-----
--=-=-=--
