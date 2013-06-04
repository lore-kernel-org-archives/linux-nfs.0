Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:63085 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755080Ab3FDOVR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2013 10:21:17 -0400
Message-ID: <51ADF789.70906@samba.org>
Date: Tue, 04 Jun 2013 16:19:53 +0200
From: "Stefan (metze) Metzmacher" <metze@samba.org>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com> <1370056054-25449-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-12-git-send-email-jlayton@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDC06D3B97CE85A15870C7A9B"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDC06D3B97CE85A15870C7A9B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

> There's no reason we have to protect the blocked_hash and file_lock_lis=
t
> with the same spinlock. With the tests I have, breaking it in two gives=

> a barely measurable performance benefit, but it seems reasonable to mak=
e
> this locking as granular as possible.

as file_lock_{list,lock} is only used for debugging (/proc/locks) after t=
his
change, I guess it would be possible to use RCU instead of a spinlock.

@others: this was the related discussion on IRC
(http://irclog.samba.org/) about this:

16:02 < metze> jlayton: do you have time to discuss your file_lock_lock
changes?
16:02 < jlayton> metze: sure, what's up?
16:03 < jlayton> metze: note that it won't help vl's thundering herd
problems...
16:03 < metze> is it correct that after your last patch file_lock_lock
is only used for /proc/locks?
16:03 < jlayton> well, it's only used to protect the list that is used
for /proc/locks
16:04 < jlayton> it still gets taken whenever a lock is acquired or
released in order to manipulate that list
16:04 < metze> would it be a good idea to use rcu instead of a spin lock?=

16:04 < jlayton> I tried using RCU, but it turned out to slow everything
down
16:04 < jlayton> this is not a read-mostly workload unfortunately
16:04 < jlayton> so doing it with mutual exclusion turns out to be faster=

16:04 < metze> ok
16:05 < jlayton> I might play around with it again sometime, but I don't
think it really helps. What we need to ensure is
                 that we optimize the code that manipulates that list,
and RCU list manipulations have larger overhead
16:06 < jlayton> metze: that's a good question though so if you want to
ask it on the list, please do
16:06 < jlayton> others will probably be wondering the same thing
16:08 < metze> maybe it's worth a comment in commit message and the code
16:08 < metze> btw, why don't you remove the ' /* Protects the
file_lock_list and the blocked_hash */' comment?

metze


--------------enigDC06D3B97CE85A15870C7A9B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlGt95EACgkQm70gjA5TCD9rgACdFM0jvnKV/2vYwljAJGQjabIq
YwgAoJeaqln0qY27+IkCDBaB/2+fGAtT
=T0cN
-----END PGP SIGNATURE-----

--------------enigDC06D3B97CE85A15870C7A9B--
