Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39317 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab3GCArs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 20:47:48 -0400
Date: Wed, 3 Jul 2013 10:47:33 +1000
From: NeilBrown <neilb@suse.de>
To: Jeffrey Layton <jlayton@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christopher T Vogan <cvogan@us.ibm.com>
Subject: Re: [PATCH v1] vfs: allow umount to handle mountpoints without
 revalidating them
Message-ID: <20130703104733.0dd1937d@notabene.brown>
In-Reply-To: <1372761278.2620.13.camel@tlielax.poochiereds.net>
References: <1372684830-13272-1-git-send-email-jlayton@redhat.com>
	<20130702114234.41cc66dc@notabene.brown>
	<1372761278.2620.13.camel@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/rk+HZRqf7x17i.VrRDpxod+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rk+HZRqf7x17i.VrRDpxod+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 02 Jul 2013 06:34:38 -0400 Jeffrey Layton <jlayton@redhat.com> wrot=
e:

> On Tue, 2013-07-02 at 11:42 +1000, NeilBrown wrote:
> > On Mon,  1 Jul 2013 09:20:30 -0400 Jeff Layton <jlayton@redhat.com> wro=
te:
> >=20
> > > Christopher reported a regression where he was unable to unmount a NFS
> > > filesystem where the root had gone stale. The problem is that
> > > d_revalidate handles the root of the filesystem differently from other
> > > dentries, but d_weak_revalidate does not. We could simply fix this by
> > > making d_weak_revalidate return success on IS_ROOT dentries, but there
> > > are cases where we do want to revalidate the root of the fs.
> > >=20
> > > A umount is really a special case. We generally aren't interested in
> > > anything but the dentry and vfsmount that's attached at that point. If
> > > the inode turns out to be stale we just don't care since the intent is
> > > to stop using it anyway.
> > >=20
> > > Try to handle this situation better by treating umount as a special
> > > case in the lookup code. Have it resolve the parent using normal
> > > means, and then do a lookup of the final dentry without revalidating
> > > it. In most cases, the final lookup will come out of the dcache, but
> > > the case where there's a trailing symlink or !LAST_NORM entry on the
> > > end complicates things a bit.
> > >=20
> > > Reported-by: Christopher T Vogan <cvogan@us.ibm.com>
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >=20
> > Thanks for this Jeff.  It certainly looks credible to me.
> >=20
> > There is a lot of code copied from the "user_path_at" path which is a s=
hame,
> > but probably better that putting in lots of "is this an unmount" tests =
which
> > would slow done the common case.
> >=20
> > On balance, I like it.
> >=20
> > Thanks,
> > NeilBrown
> >=20
>=20
> (cc'ing Christopher as I mistakenly left him off the original mail. I'll
> make sure to cc him on any respins...)
>=20
> Thanks for looking. Yeah it is a lot of code to handle one case. So,
> while this does seem to work, I'm still not 100% sold on this
> approach...
>=20
> I had assumed that we would sometimes want to revalidate IS_ROOT
> dentries in other codepaths. Now that I think about it though, I'm
> having a hard time coming up with any situations where that's
> necessary. We'll never want to invalidate such a dentry, so does that
> ever make sense?

What does "revalidate" mean exactly here?  I think this is d_revalidate, so
it is validating the entry in the dcache, so it is "validating that the name
still leads to the inode".  Is that correct?

In that case as IS_ROOT has no name it is hard to imagine that it needs to =
be
revalidated.

However I don't think a mount point is always IS_ROOT.
With NFSv4 (an possibly the other NFS versions as well), if I
   mount server:/some/path /mnt
then the NFS client will internally "mount" server:/, walk down to find
"/some/path", and then bind that to /mnt.

In that case I would argue that it is really the inode found at "/some/path=
",
rather than the textual name "/some/path" which is being bound.
So when stepping from one filesystem, to the next over a mount point, it is
pointless to try to revalidate the dentry because it is really the inode th=
at
we want.

However it could be that "revalidate" means "check that this inode still
exists, and is still the same sort of object (directory or file)".   If that
is what we mean by "revalidate", then "umount" really is a special case as
everything else would want to know that the object is still then, but umount
wouldn't.

Thinking a bit more: I see "umount" as a bit like "lstat".  With "lstat", if
the last component is a symlink we don't follow it, we just return it.
With "umount" if the last component is a mountpoint we really don't want to
follow it but rather return the underlying dentry.

Once "umount" does the lookup and gets the dentry that something was mounted
on to, it can carefully attach whatever is mounted there without ever
"touching" it.  (of couse if there are a stack of things mounted it need to
only detach the last).



Do those thoughts help at all?  Or just add confusion?

NeilBrown


>=20
> If it doesn't, we could just replace this patch with a test for
> IS_ROOT(dentry) in nfs_weak_revalidate, and call it a day. I tested a
> patch like that earlier and it also worked around the problem.
>=20
> Also, it bothers me a little that this patch stops revalidating anything
> once it hits the last component, even if it's a symlink and we know
> we'll have to chase it down. It may make sense to check for d_mountpoint
> in some cases and revalidate the dentry if it's true.
>=20
> Thoughts?


--Sig_/rk+HZRqf7x17i.VrRDpxod+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdN0pTnsnt1WYoG5AQJzSw/9HRZ0SdvWx/RUJe3extO/a3+brgf70Amh
vFrvuKejnylMo6DvyVAQdKwk0SfywYf4EKFbnLx1T5Zu4sNkhnhM1K0J2JwYpZEY
bkRQgzhOeQ3FL6Wdfed7O2TCaC5LAi59QSNrdTDg6CGi+31d3zU18uE/eIXEek7M
jWx5ErzF7EzY3ZSiKVbszDisB+N9lSIeLR3OoxWHPYqfw2fNtAuW6mIwRhWSCJDE
BO2uGsPTMRcuiBJX4XS3+Mezt5DgFBd9ldrh9Vb+rGrmXCsJljwtN0Ak24ULRnwv
pF3CSJa6M78xgi6+BVd1Yf3IotgwInwd3SgRnZ30smCMpbRqlAbAywgNKTs7XsNR
3o0aQX9uQqnAvWMoKZu0nrYarEWRl13L5fnhfJ3SY4/YBXvRAg7XOPngmcKk+h/Y
6d2srfXWF+PKr3/kpjTpN0L3hW1Qc30VnwTlpJfMz+Fn2w98pkyrvZU7ouUptXmN
PcT57heb4omcBUWw4OGbzgjO8EOk+h6pW3gC9Ia8tOzpErdlfnFg1LjTlkFHURjV
TKSPg7Vjf7s7LpaV+Yc46hzSgcrxfjGBsi/PfUIWBAE/glOhqW+4jYFEDltCCBq+
rkLqq3pUPrEdzfxf+eQm0AwDfb7nLDHdWR9zIdKx1ZNJaB1DtLt2bYGPzX2pjIwE
/llCFMa3ZWI=
=4HW5
-----END PGP SIGNATURE-----

--Sig_/rk+HZRqf7x17i.VrRDpxod+--
