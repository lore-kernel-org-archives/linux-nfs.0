Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40241 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750961AbdIDEw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Sep 2017 00:52:59 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Date: Mon, 04 Sep 2017 14:52:43 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <20170901161809.GA22140@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-3-git-send-email-bfields@redhat.com> <878ti4i9pi.fsf@notabene.neil.brown.name> <20170829214026.GI8822@parsley.fieldses.org> <8760d5hol3.fsf@notabene.neil.brown.name> <20170830170938.GC24373@parsley.fieldses.org> <87wp5kfxi3.fsf@notabene.neil.brown.name> <20170831190531.GA8223@parsley.fieldses.org> <873787fhc5.fsf@notabene.neil.brown.name> <20170901161809.GA22140@parsley.fieldses.org>
Message-ID: <871snndq04.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 01 2017, J. Bruce Fields wrote:

>>=20
>> nfsd would need to find that delegation, prevent further delegations
>> being handed out, and check that there aren't already conflicting
>> delegations.  If there are conflicts, recall them.  Once there are no
>> conflicting delegations, make the vfs_ request.
>
> The way that we currently serialize setting, unsetting, and breaking
> delegations is by locks on the delegated inodes which aren't taken till
> deeper in the vfs code.

Do we?
I can see nfs4_set_delegation adding a new delegation for a new client
without entering the vfs at all if there is already a lease held.
If there isn't a lease already, vfs_setlease() is called, which doesn't
its own internal locking of course.  Much the same applies to unsetting
delegations.
Breaking delegations involves nfsd_break_deleg_cb() which has a comment
that it is called with i_lock held.... that seems to be used to
be sure that it is safe to a reference to the delegation state id.
Is that the only dependency on the vfs locking, or did I miss something?

>
> I guess you're suggesting adding a second mechanism to prevent
> delegations being given out on the inode.  We could add an atomic
> counter taken by each nfsd breaker while it's in progress.  Hrm.

Something like that.
We would also need to be able to look up an nfs4_file by inode (why
*are* they hashed by file handle??) and add some wait queue somewhere
so the breaker could wait for a delegation to be returned.

My big-picture point is that any complexity created by NFSD's choice to
merge delegations to multiple clients into a single vfs-level delegation
should be handled by NFSD, and not imposed on the VFS.
It certainly makes sense for the VFS to understand that certain
operations are being performed by an fl_owner_t, and to allow
delegations to that owner to remain.  It doesn't make as much sense for
the VFS to understand that there is a finer granularity of ownership
than the one that it already supports.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlms3B0ACgkQOeye3VZi
gbnvxg/+LlMdokAEr9lIrYLgLsUwCdGZEwXKUmzuV2o6Rbn4zau/IXoTvylAOsU5
tLtzYpQtgDoxaJr0mgL24QBlllopsS287QZgbbH8gZ02h/8d0Ovp94eVIAykhdu3
oS8Dsn1Tya/icsD5EPRtBddLikBGE+qEhuxo0z1+hs80Vg5R2aFiZ8q+ikici8BV
iDEzc8JwjKoj+X8pWPUYdg+o9ckHqXXEMgGYslXpLPYu2//c+SjvW+cW9u9ic7D6
wNJlWQnabxYWTsWlKiIWkTVnFNaciGATIwamH/GOMZ/uGt7sRNEcy4eBhWZBAIzp
wCKSKRh6FR9pPoTKd6JmI2Q+oVrrvWvfA5N8QUYHxeC0ihShCweW/RChlgMLmC4v
ylNdywHIAG50Ln/evM1T2An+0iFRxXqMfN0ULgcIg6ovchvN14849lC+xYcNqugV
78UrjA+EJ9c7GnsRGQaTEPWEOJDW3uKA3p+NY2ABhiWUEavVPgVCrBlseURjbdww
4UU/x4un8xr63B+WnB4FXpRpXw2p/yXBe6sZUTok6ADTNPTVfiKpUtpo89+yJnYg
859inIOhmtOyuEnM6UjWjPFAZVRvCXqZ44K9W1Q3CTZY/6ctHyNjExlix+iFaVZN
hI5MbiNyZW/9ILnN+hzosV8YScaNPTs+iwiHWPz3SYI92XF6jdQ=
=ikwy
-----END PGP SIGNATURE-----
--=-=-=--
