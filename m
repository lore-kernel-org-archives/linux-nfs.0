Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52895 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755787Ab3GBBmt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 21:42:49 -0400
Date: Tue, 2 Jul 2013 11:42:34 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1] vfs: allow umount to handle mountpoints without
 revalidating them
Message-ID: <20130702114234.41cc66dc@notabene.brown>
In-Reply-To: <1372684830-13272-1-git-send-email-jlayton@redhat.com>
References: <1372684830-13272-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qMnGK5yg3thVf2Y=DY.vWbG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qMnGK5yg3thVf2Y=DY.vWbG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon,  1 Jul 2013 09:20:30 -0400 Jeff Layton <jlayton@redhat.com> wrote:

> Christopher reported a regression where he was unable to unmount a NFS
> filesystem where the root had gone stale. The problem is that
> d_revalidate handles the root of the filesystem differently from other
> dentries, but d_weak_revalidate does not. We could simply fix this by
> making d_weak_revalidate return success on IS_ROOT dentries, but there
> are cases where we do want to revalidate the root of the fs.
>=20
> A umount is really a special case. We generally aren't interested in
> anything but the dentry and vfsmount that's attached at that point. If
> the inode turns out to be stale we just don't care since the intent is
> to stop using it anyway.
>=20
> Try to handle this situation better by treating umount as a special
> case in the lookup code. Have it resolve the parent using normal
> means, and then do a lookup of the final dentry without revalidating
> it. In most cases, the final lookup will come out of the dcache, but
> the case where there's a trailing symlink or !LAST_NORM entry on the
> end complicates things a bit.
>=20
> Reported-by: Christopher T Vogan <cvogan@us.ibm.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks for this Jeff.  It certainly looks credible to me.

There is a lot of code copied from the "user_path_at" path which is a shame,
but probably better that putting in lots of "is this an unmount" tests which
would slow done the common case.

On balance, I like it.

Thanks,
NeilBrown


--Sig_/qMnGK5yg3thVf2Y=DY.vWbG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdIwCjnsnt1WYoG5AQLM8A/+NTFymaQXog63gR0F5qudz/+lQ3j0XHKP
eSkp0rNU7SGMvlTtv743d+TRcslyMLevAcVopNRlUE/5ofQoF/86svUo3TqQjA9+
AELykabH0XnCtN1OROZJ16cy4PBvlx7gYgJ6Rz4KWz2/wEfVDEDdAZfyVQAfstZZ
6VWYmgilOmgfeJHvmGkvvPzBpjOwjjqeItZmqxk0jqVkFxxi3QPDnesx7gaSj/WL
WWGIx/j/i/+h1nIGSv5t2R2xjuU9RMe8gJm8e4YnpbbZ7pnvi2u8o5IYuPm7n0/A
CPiZesC9pfUIpo2dplApj2CRK3KnAJycQ3qlkmscULC4lREcxwM7Fa97vLuuqj6S
+DWq5X+Hin0Z8hBbgNFYnqL9oFiK0vd8AN7aXcQwseZ3V8ipw3H5DD+r4eIL5plj
tH4GYlWr6H6bJ6WCrjFpoYahC9IJRuVgKXFtHIWfQ0z0SsKmly4M96seTL/k4xmX
iZsKgWXuq6Di6q2g5ORKXqkMxv7r4OSq8JMbkJNjV1eAB4aBBNjkGfcBfW/7twyx
AO9ln2tw/wkQGfQKHS5yYFhXjjhjMSvbmWJcegILr4oTPLsOSn8799wFl+Jd3bpJ
oqbX1E0d4msga0XBS1bChxxO8rFAy95cLPpUnT0pszKDisapB6DM3rATaWSfURrt
mtveVX10eKA=
=Am5J
-----END PGP SIGNATURE-----

--Sig_/qMnGK5yg3thVf2Y=DY.vWbG--
