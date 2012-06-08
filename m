Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:12309 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab2FHWNd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 18:13:33 -0400
Date: Sat, 9 Jun 2012 01:14:46 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
        Nick Piggin <npiggin@kernel.dk>, "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@TELEMANN.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120608221446.GA18250@otc-wbsnb-06>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608150253.e42464a6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
In-Reply-To: <20120608150253.e42464a6.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 08, 2012 at 03:02:53PM -0700, Andrew Morton wrote:
> On Sat,  9 Jun 2012 00:41:03 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > There's no reason to call rcu_barrier() on every deactivate_locked_supe=
r().
> > We only need to make sure that all delayed rcu free inodes are flushed
> > before we destroy related cache.
> >=20
> > Removing rcu_barrier() from deactivate_locked_super() affects some
> > fas paths. E.g. on my machine exit_group() of a last process in IPC
> > namespace takes 0.07538s. rcu_barrier() takes 0.05188s of that time.
>=20
> What an unpleasant patch.  Is final-process-exiting-ipc-namespace a
> sufficiently high-frequency operation to justify the change?
=20
> I don't really understand what's going on here.  Are you saying that
> there is some filesystem against which we run deactivate_locked_super()
> during exit_group(), and that this filesystem doesn't use rcu-freeing
> of inodes?  The description needs this level of detail, please.

I think the rcu_barrier() is in wrong place. We need it to safely destroy
inode cache. deactivate_locked_super() is part of umount() path, but all
filesystems I've checked have inode cache for whole filesystem, not
per-mount.

> The implementation would be less unpleasant if we could do the
> rcu_barrier() in kmem_cache_destroy().  I can't see a way of doing that
> without adding a dedicated slab flag, which would require editing all
> the filesystems anyway.

I think rcu_barrier() for all kmem_cache_destroy() would be too expensive.
=20
=20
> (kmem_cache_destroy() already has an rcu_barrier().  Can we do away
> with the private rcu games in the vfs and switch to
> SLAB_DESTROY_BY_RCU?)

--=20
 Kirill A. Shutemov

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP0nlWAAoJEAd+omnVudOMmbEP/13S9Evr5LclYc6Vfqwj8xrb
jk/Q93iEc0pcUv+/wkCpJZ/FyU3MY/GAKzIKjtYnHInou17Eq1SFI7MFeAFH+foP
PKgfXij3cTzBAHe1qJMfYHFveiXxUxrjXN8ki3RL9Ogv9Vv9QmgDH5qBV6uE+Tb7
mYJH3Vlze6j3AI6d0jxh3wxLYtYQ4SWGp7YYO+CgXyzxDnc+ve6OaJI//GSsy3L0
Aapqi5e2nBwM3WiDSc/EbHsqWG/MmFqv5A0qeE2invTbgfh8r174KWk/vSq2G65I
2S4nJae/sk5iTeRbs83su+yj7Ku9wxFOW/0T6tDueF+hzGKJ92xaXt13oHuf8vOX
nMeEVuN+tLi+rAjhx0HULAXcd3X4Go2T5r6AxtgUZyuJTCdHEI22E8/kxhJh+9vJ
GrPJRdFJ6f5SCdTNZc7CJK8jG0PACl1qhdfceNIMDgQfA88QptuDvcBFxLYVyuh2
urkoMg/bf30rEWYf5wGyEeP3zb/CIxh0VtRbXOzfRvTUZoQcMHLZKttrxnkDNPTP
y7aenO8Efy5X8BTnYbW4jjNAPw7EWcCLfgrtMMgb4ZmfRS98yCtEJEawDFSOEas2
r0Tr/9L8ukjVDPisNEMj1op02KhGJmfB+++m1bTnpkjIr0P7BxBzoQFTBI6lDMo/
R2eRrtK96/pv3fX/bA5P
=XBsY
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
