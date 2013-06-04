Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712Ab3FDOkQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 10:40:16 -0400
Date: Tue, 4 Jun 2013 10:39:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Message-ID: <20130604103935.2a6afb29@corrin.poochiereds.net>
In-Reply-To: <51ADF789.70906@samba.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-12-git-send-email-jlayton@redhat.com>
	<51ADF789.70906@samba.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/e2QNgN_ZjCXlXB6Bdx9hIy+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/e2QNgN_ZjCXlXB6Bdx9hIy+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 04 Jun 2013 16:19:53 +0200
"Stefan (metze) Metzmacher" <metze@samba.org> wrote:

> Hi Jeff,
>=20
> > There's no reason we have to protect the blocked_hash and file_lock_list
> > with the same spinlock. With the tests I have, breaking it in two gives
> > a barely measurable performance benefit, but it seems reasonable to make
> > this locking as granular as possible.
>=20
> as file_lock_{list,lock} is only used for debugging (/proc/locks) after t=
his
> change, I guess it would be possible to use RCU instead of a spinlock.
>=20
> @others: this was the related discussion on IRC
> (http://irclog.samba.org/) about this:
>=20
> 16:02 < metze> jlayton: do you have time to discuss your file_lock_lock
> changes?
> 16:02 < jlayton> metze: sure, what's up?
> 16:03 < jlayton> metze: note that it won't help vl's thundering herd
> problems...
> 16:03 < metze> is it correct that after your last patch file_lock_lock
> is only used for /proc/locks?
> 16:03 < jlayton> well, it's only used to protect the list that is used
> for /proc/locks
> 16:04 < jlayton> it still gets taken whenever a lock is acquired or
> released in order to manipulate that list
> 16:04 < metze> would it be a good idea to use rcu instead of a spin lock?
> 16:04 < jlayton> I tried using RCU, but it turned out to slow everything
> down
> 16:04 < jlayton> this is not a read-mostly workload unfortunately
> 16:04 < jlayton> so doing it with mutual exclusion turns out to be faster
> 16:04 < metze> ok
> 16:05 < jlayton> I might play around with it again sometime, but I don't
> think it really helps. What we need to ensure is
>                  that we optimize the code that manipulates that list,
> and RCU list manipulations have larger overhead
> 16:06 < jlayton> metze: that's a good question though so if you want to
> ask it on the list, please do
> 16:06 < jlayton> others will probably be wondering the same thing
> 16:08 < metze> maybe it's worth a comment in commit message and the code


I'm not sure it's worth commenting about RCU in the code. In the future
it may be possible to do this -- who knows. It does seem to have been
consistently slower in my testing here though.

> 16:08 < metze> btw, why don't you remove the ' /* Protects the
> file_lock_list and the blocked_hash */' comment?
>=20

Removed in my git tree -- thanks for pointing that out.

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/e2QNgN_ZjCXlXB6Bdx9hIy+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRrfwuAAoJEAAOaEEZVoIVYlsP/0suyZxDnd28BxQxkQHllqG5
bxXk07dLel27h/VoWr9UUXVuGmWRx/+Ue0omtVewfMiSeBrpkUXBkYKI7dHMpoD8
SH7qQNvUDP+A1Y1Eup/+UQlXVX8ykSFzMzn283wvPaqXtUrhCVflGQQZjXW062RG
C7aodjNQspdcBh5+5J8XQO2s7jQA6xy/mxEvvBrlV1Rjq1/3iW8xQr59dOjGiLID
mlMqitLPpz8Os9kX5ONp+hyffVLK+OuaA8hLaInHMiYbDH3NV08WerfhHzy7wySt
G/hlzs7P2zub9rT77PNTXYa5Aj9UOzAYihYUFcKH9RzWqfdD2XKPsIj7JGr5KCLA
pmEemZdmBVFqn5nKzggGrZBssju2c97mKumII51oJr62wV/M8ISS89rsPtFxdlTW
Qs+gSi1fH+PuzUTsFJw/hC9QM0bsAo1AmB2mmT4ijbynxqmgjB7bDAe1soGp6CNI
m/diYluiPh5gBa6WxoFpjMyJPWRrTvIv8XsUUS3NaSDiCdKWrXiN7/fYdy0q8Tkm
Ve6w/vPuN7/2rmsqh3sJkV8S7kQHQwD2/lxcFKkD/CqGy+AyC4YCwIqxYLLwh127
vxKCdU9Ng97qhTQUIiq4s1EZAgTC7Jpe3hdwbAxfoA1r0xgl2kfdEYKmdZ3HsYCX
0jwGrRwaGKkUpR/ILxVq
=qRHI
-----END PGP SIGNATURE-----

--Sig_/e2QNgN_ZjCXlXB6Bdx9hIy+--
