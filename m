Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55005 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755384AbaFDHjg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 03:39:36 -0400
Date: Wed, 4 Jun 2014 17:39:26 +1000
From: NeilBrown <neilb@suse.de>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140604173926.53918af3@notabene.brown>
In-Reply-To: <20140531081358.62ae69b3@notabene.brown>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
	<20140531081358.62ae69b3@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/d+AkacslqdKT7cfD4TUc7eT"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/d+AkacslqdKT7cfD4TUc7eT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 31 May 2014 08:13:58 +1000 NeilBrown <neilb@suse.de> wrote:

> On Fri, 30 May 2014 17:55:23 -0400 "J. Bruce Fields" <bfields@fieldses.or=
g>
> wrote:
>=20
> > On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
> > > On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fieldse=
s.org>
> > > wrote:
> > >=20
> > > > Yes, it's a known server bug.
> > > >=20
> > > > As a first attempt I was thinking of just sticking a timestamp in s=
truct
> > > > inode to record the time of the most recent conflicting access and =
deny
> > > > delegations if the timestamp is too recent, for some definition of =
too
> > > > recent.
> > > >=20
> > >=20
> > > Hmmm... I'll have a look next week and see what I can come up with.
> >=20
> > Thanks!
> >=20
> > If we didn't think it was worth another struct inode field, we could
> > probably get away with global state.  Even just refusing to give out any
> > delegations for a few seconds after any delegation break would be enough
> > to fix this bug.
> >=20
> > Or you could make it a little less harsh with a small hash table: "don't
> > give out a delegation on any inode whose inode number hashes to X for a
> > few seconds."
>=20
> I was thinking of using a bloom filter - or possibly two.
> - avoid handing out delegations if either bloom filter reports a match
> - when reclaiming a delegation add the inode to the second bloom filter
> - every so-often zero-out the older filter and swap them.
>=20
> Might be a bit of overkill, but I won't know until I implement it.
>=20

Below is my suggestion.  It seems easy enough.  It even works.

However it does raise an issue with the NFS client.

NFS performs a silly-rename as an 'asynchronous' operation.  One consequence
of this is that NFS4ERR_DELAY always results in a delay of
NFS4_POLL_RETRY_MAX (15*HZ), where as sync requests use an exponential scale
from _MIN to _MAX.

So in my test case there is always a 15second delay:
  - try to silly-rename
  - get NFS4ERR_DELAY
  - server reclaim delegation
  - 15 seconds passes
  - retry silly-rename - it works.

I hacked the NFS server to store a timeout in 'struct nfs_renamedata', and
use the same exponential retry pattern and the 15 seconds (obviously)
disappeared.

Trond: would  you accept a patch which did that more generally?  e.g. pass a
timeout pointer to nfs4_async_handle_error() and various *_done function pa=
ss
a pointer to a field in their calldata?

NeilBrown


NFSD: Don't hand out delegations for 30 seconds after recalling them.

If nfsd needs to recall a delegation for some reason it implies that there =
is
contention on the file, so further delegations should not be handed out.

We could simply avoid delegations for (say) 30 seconds after any recall, but
this is probably too heavy handed.

We could keep a list of inodes (or inode numbers or filehandles) for recall=
ed
delegations, but that requires memory allocation and searching.

The approach taken here is to use a bloom filter to record the filehandles
which are currently blocked from delegation, and to accept the cost of a few
false positives.

We have 2 bloom filters, each of which is valid for 30 seconds.   When a
delegation is recalled the filehandle is added to one filter and will remain
disabled for between 30 and 60 seconds.

We keep a count of the number of filehandles that have been added, so when
that count is zero we can bypass all other tests.

The bloom filters have 256 bits and 3 hash functions.  This should allow a
couple of dozen blocked  filehandles with minimal false positives.  If many
more filehandles are all blocked at once, behaviour will degrade towards
rejecting all delegations for between 30 and 60 seconds, then resetting and
allowing new delegations.


diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9a77a5a21557..45101b41fb04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -41,6 +41,7 @@
 #include <linux/ratelimit.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/addr.h>
+#include <linux/hash.h>
 #include "xdr4.h"
 #include "xdr4cb.h"
 #include "vfs.h"
@@ -364,6 +365,79 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(str=
uct nfs4_client *clp)
 	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
 }
=20
+/*
+ * When we recall a delegation, we should be careful not to hand it
+ * out again straight away.
+ * To ensure this we keep a pair of bloom filters ('new' and 'old')
+ * in which the filehandles of recalled delegations are "stored".
+ * If a filehandle appear in either filter, a delegation is blocked.
+ * When a delegation is recalled, the filehandle is stored in the "new"
+ * filter.
+ * Every 30 seconds we swap the filters and clear the "new" one,
+ * unless both are empty of course.
+ *
+ * Each filter is 256 bits.  We hash the filehandle to 32bit and use the
+ * low 3 bytes as hash-table indices.
+ *
+ * 'recall_lock', which is always held when block_delegations() is called,
+ * is used to manage concurrent access.  Testing does not need the lock
+ * except when swapping the two filters.
+ */
+static struct bloom_pair {
+	int	entries, old_entries;
+	time_t	swap_time;
+	int	new; /* index into 'set' */
+	DECLARE_BITMAP(set[2], 256);
+} blocked_delegations;
+
+static int delegation_blocked(struct knfsd_fh *fh)
+{
+	u32 hash;
+	struct bloom_pair *bd =3D &blocked_delegations;
+
+	if (bd->entries =3D=3D 0)
+		return 0;
+	if (seconds_since_boot() - bd->swap_time > 30) {
+		spin_lock(&recall_lock);
+		if (seconds_since_boot() - bd->swap_time > 30) {
+			bd->entries -=3D bd->old_entries;
+			bd->old_entries =3D bd->entries;
+			memset(bd->set[bd->new], 0,
+			       sizeof(bd->set[0]));
+			bd->new =3D 1-bd->new;
+			bd->swap_time =3D seconds_since_boot();
+		}
+		spin_unlock(&recall_lock);
+	}
+	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
+	if (test_bit(hash&255, bd->set[0]) &&
+	    test_bit((hash>>8)&255, bd->set[0]) &&
+	    test_bit((hash>>16)&255, bd->set[0]))
+		return 1;
+
+	if (test_bit(hash&255, bd->set[1]) &&
+	    test_bit((hash>>8)&255, bd->set[1]) &&
+	    test_bit((hash>>16)&255, bd->set[1]))
+		return 1;
+
+	return 0;
+}
+
+static void block_delegations(struct knfsd_fh *fh)
+{
+	u32 hash;
+	struct bloom_pair *bd =3D &blocked_delegations;
+
+	hash =3D arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
+
+	__set_bit(hash&255, bd->set[bd->new]);
+	__set_bit((hash>>8)&255, bd->set[bd->new]);
+	__set_bit((hash>>16)&255, bd->set[bd->new]);
+	if (bd->entries =3D=3D 0)
+		bd->swap_time =3D seconds_since_boot();
+	bd->entries +=3D 1;
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, str=
uct svc_fh *current_fh)
 {
@@ -372,6 +446,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_o=
l_stateid *stp, struct sv
 	dprintk("NFSD alloc_init_deleg\n");
 	if (num_delegations > max_delegations)
 		return NULL;
+	if (delegation_blocked(&current_fh->fh_handle))
+		return NULL;
 	dp =3D delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp =3D=3D NULL)
 		return dp;
@@ -2742,6 +2818,8 @@ static void nfsd_break_one_deleg(struct nfs4_delegati=
on *dp)
 	/* Only place dl_time is set; protected by i_lock: */
 	dp->dl_time =3D get_seconds();
=20
+	block_delegations(&dp->dl_fh);
+
 	nfsd4_cb_recall(dp);
 }
=20

--Sig_/d+AkacslqdKT7cfD4TUc7eT
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU47NLjnsnt1WYoG5AQLcPRAAonZxUEPu0R4y8WOEvCxtcbhHvk2f1oop
omAy5oZo2a1DDcXU+mXJgngBuIf52Bt6/N4gmHtPXTzVyYHZ3tWMykg3l2ShGRTv
g30rP5JFiDe9hECIVw4kyO4zi86HGqeuhLOJPhbMjFIU/TlyzlCdv39mWkRnpJfh
AZU1sRQ/Uj/ippmDSLuPTrvBYds7vgN96+bWVumx93t71M5ySyyFYnHMasiV2dTk
gxcEGNrl1PK0y5rq6Y2DLDLzeJoiV1romn6FmYpQgidKgBbg45sdn5R13rcgk+oI
C0WMox+1+mpg4zwYjoy9Ix8qxMYQET+hxtpfAz2hj9eHykqa1UKhHESAS18q7+5F
cB4lAxTJ1cgLNxaEbO/yY73baPM+/ANGDKfwdLu1GFwfWbcTgPNEwWYVMuE+4eL3
GwdIqTd09oBBXRr6ADpOKP2TLjgkg/EUEvR6GJ2vmYlTVyUaQKL8RKdW07W2Mo1e
ZjVf0u6vWJop0K5jnOA7EIryB/Vn5oaclQjYPxxjE4W1e4+GAp99mAjc0j+isj8A
+KCJ4wNz1cGEOFsUuLZz5cbnnV1WVjuur6SIR8dz5V62kNfqXYzKUPULbnnXKqOe
VczcIWW7pv3MXICscNuiQa/Two1OIQ6W1ZcSSl1QVdNZ4gq/+TRY9cronyB0PXGw
W4EQXXlbKbE=
=IqOa
-----END PGP SIGNATURE-----

--Sig_/d+AkacslqdKT7cfD4TUc7eT--
