Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38303 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3FEGTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 02:19:48 -0400
Date: Wed, 5 Jun 2013 16:19:34 +1000
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130605161934.59ab6804@notabene.brown>
In-Reply-To: <20130605034115.GD13110@ZenIV.linux.org.uk>
References: <20130605130541.5968d5c2@notabene.brown>
	<20130605034115.GD13110@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.HF8c3N8hJTKtfXctIqBmF3"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.HF8c3N8hJTKtfXctIqBmF3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Jun 2013 04:41:15 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> >=20
> > Hi Bruce,
> >  this is a little issue that seems to keep coming up so I thought it mi=
ght be
> >  time to fix it.
> >=20
> >  As you know, a filesystem that is exported cannot be unmounted as the =
export
> >  cache holds a reference to it.  Though if it hasn't been accessed for a
> >  while then it can.
> >=20
> >  As I hadn't realised before sometimes *non* exported filesystems can be
> >  pinned to.  A negative entry in the cache can pin a filesystem just as
> >  easily as a positive entry.
> >  An amusing, if somewhat contrived, example is that if you export '/' w=
ith
> >  crossmnt and:
> >=20
> >     mount localhost:/ /mnt
> >     ls -l /
> >     umount /mnt
> >=20
> >  the umount might fail.  This is because the "ls -l" tried to export ev=
ery
> >  filesystem found mounted in '/'.  The export of "/mnt" failed of course
> >  because you cannot re-export an NFS filesystem.  But it is still in the
> >  cache.
> >  An 'exportfs -f' fixes this, but shouldn't be necessary.
> >=20
> >  So this RFC patch makes it possible  to register a notifier which gets
> >  called on unmount, and links the export table in to the notifier chain.
> >=20
> >  The "atomic" flavour is used so that notifiers can be registered under=
 a
> >  spin_lock.  This is needed for "expkey_update" as ->update is called u=
nder a
> >  lock.
> >=20
> >  As notifier callees cannot unregister themselves, the unregister needs=
 to
> >  happen in a workqueue item, and the unmount will wait for that.
> >=20
> >  It seems to work for me (once I figured out all the locking issues and=
 found
> >  a way to make it work without deadlocking).
> >=20
> >  If you are OK with in in general I'll make it into a proper patch seri=
es and
> >  include Al Viro for the VFS bits.
>=20
> > @@ -1201,6 +1234,11 @@ static int do_umount(struct mount *mnt, int flag=
s)
> >  		sb->s_op->umount_begin(sb);
> >  	}
> > =20
> > +	/* Some in-kernel users (nfsd) might need to be asked to release
> > +	 * the filesystem
> > +	 */
> > +	umount_notifier_call(mnt);
>=20
> NAK.  I'm sorry, but it's a fundamentally wrong approach - there are _ton=
s_
> of places where vfsmount could get evicted (consider shared-subtree umount
> propagation, for starters), not to mention that notifiers tend to be
> the wrong answer to just about any question.
>=20
> I'd suggest looking at what kernel/acct.c is doing; I'm absolutely serious
> about notifiers being unacceptable BS.  If you want something generic,
> consider turning ->mnt_pinned into a list of callbacks, with mntput_no_ex=
pire
> calling them one by one; calling acct_auto_close_mnt() would be replaced =
with
> callbacks, each doing single acct_file_reopen(acct, NULL, NULL).
>=20
> I'm about to fall asleep right now, so any further details will have to w=
ait
> until tomorrow; sorry...

When tomorrow does come:

 - Can you say why you don't like notifiers?

 - mnt_pinned handling happens *after* the unmount has happened.  The unmou=
nt
   is effectively always 'lazy' with respect to pinning users.  I don't thi=
nk
   I want that.
   If an NFS request is in progress when the unmount is requested, I think =
it
   should fail, and with my code it will - the notifier handler will expire
   the cache entries but they will continue to exist until the last user go=
es
   away.
   For most requests it probably wouldn't matter if they continued on a
   lazy-unmounted filesystem, but the NFSv4 LOOKUPP (lookup parent)
   request might get confused.

 - Your point about shared subtree umount certainly deserved consideration.
   It is probably time I wrapped my mind around that that really means.
   Putting the umount_notifier_call() call in do_refcount_check() might
   almost be the right place, except that it would introduce even more
   locking problems (unless it is OK to call flush_sheduled_work() under
   vfsmount_lock).

Thanks for the feedback.  I'm very open to other ideas.

NeilBrown

--Sig_/.HF8c3N8hJTKtfXctIqBmF3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa7Ydjnsnt1WYoG5AQKJ6A//eBLK+Oq6/gNBEVYiNbkNepP/GReM/DnU
G6yKihgWUrgfByZPH1lVr9hL9kQnp8LppdK6+IGwsoW/kxVHvnEIY9DgJHJyi90O
6eSG7LuU0FU/ja4UF0RhNnjAkVSFioIS3Kj7mZ1tXoFofOWqL5CRZIWY7JmMlVY9
2zpNLtysPPwOTn5NzH0JLP181o/MIImq3O5Sw2tBDhHu2OnJEfiaR/DIypT3FSb+
lI3EZzGfAKBRew1AScu2Tx49ce1Bp8VlgvBFWR+aMUe72/RYY+ExaTF4BMgtWsgb
uvXUFMZCAqFdODG4rEIL/K5XXrZ2HSEflR2BbRLsVfWJqqP8n4igMVuAcbXm5N63
Kpvu1aX+3P127S4cjbZOl/71BAggNDVThUxWtz15aDvn4/lzUMQwxn3YKtHiVCp5
KBz473BzWLiO77Ue2UOB6oCKBHlBeAEJl9htETy6tOIYq5WTpAdKKSb8kEvR0Cgc
9Wi67P9cARcL4e8aRohvQCKy350EzKc2tDJVJmopD4dGNC+uUbr7Uz2pIp+V9MnX
RxkVIdfr5U8SGTgUn//9BPxMmdorUd8rMum8dOHIp0cM86Yi41Wl7XhbP/+vSaLy
KEXWr3N71lczuUXAxVQ21fzVzefOwIF3IwONMB21sTL2nj68RVfrC52rFZOq0ZaU
Ck7yKRGWjJo=
=vEYM
-----END PGP SIGNATURE-----

--Sig_/.HF8c3N8hJTKtfXctIqBmF3--
