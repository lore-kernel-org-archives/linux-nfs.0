Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34163 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208Ab2IYF1i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 01:27:38 -0400
Date: Tue, 25 Sep 2012 15:27:31 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
Message-ID: <20120925152731.52528dca@notabene.brown>
In-Reply-To: <20120829151641.20cde4bc@corrin.poochiereds.net>
References: <20120829162527.GA3635@NickAndBarb.net>
 <20120829151641.20cde4bc@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Gt_xaRBbM3TLI8nbCFsrySF"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Gt_xaRBbM3TLI8nbCFsrySF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Aug 2012 15:16:41 -0700 Jeff Layton <jlayton@redhat.com> wrote:


> This stack trace comes from cifs, not nfs.

It's quite easy to trigger on NFS too.

 mount server:/path /mnt; exec 3>& /mnt/foo ; rm /mnt/foo; rm /mnt/.nfs* ;
 exec 3>&-

[634155.004438] WARNING:
at /home/abuild/rpmbuild/BUILD/kernel-desktop-3.5.0/lin [634155.004442]
Hardware name: Latitude E6510 [634155.004577]  crc_itu_t crc32c_intel
snd_hwdep snd_pcm snd_timer snd soundcor [634155.004609] Pid: 13402, comm:
bash Tainted: G        W    3.5.0-36-desktop # [634155.004611] Call Trace:
[634155.004630]  [<ffffffff8100444a>] dump_trace+0xaa/0x2b0
[634155.004641]  [<ffffffff815a23dc>] dump_stack+0x69/0x6f
[634155.004653]  [<ffffffff81041a0b>] warn_slowpath_common+0x7b/0xc0
[634155.004662]  [<ffffffff811832e4>] drop_nlink+0x34/0x40
[634155.004687]  [<ffffffffa05bb6c3>] nfs_dentry_iput+0x33/0x70 [nfs]
[634155.004714]  [<ffffffff8118049e>] dput+0x12e/0x230
[634155.004726]  [<ffffffff8116b230>] __fput+0x170/0x230
[634155.004735]  [<ffffffff81167c0f>] filp_close+0x5f/0x90
[634155.004743]  [<ffffffff81167cd7>] sys_close+0x97/0x100
[634155.004754]  [<ffffffff815c3b39>] system_call_fastpath+0x16/0x1b
[634155.004767]  [<00007f2a73a0d110>] 0x7f2a73a0d10f

Is this suitable for -stable?  It seems like it is just a harmless warning.

NeilBrown


Subject: NFS: avoid warning from nfs_drop_nlink

If you remove a file which is open, NFS will 'silly-rename' it to a
hidden file.
If you then remove that hidden file, and then close the open file,
then nfs_dentry_iput will perform an extra drop_nlink().
Since 3.3-rc1, this has produced a warning.
The simplest way to suppress it is to use "nfs_drop_nlink" which
checks for i_nlink being zero.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 627f108..268af03 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1174,7 +1174,7 @@ static void nfs_dentry_iput(struct dentry *dentry,
struct inode *inode) NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_DATA;
=20
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
-		drop_nlink(inode);
+		nfs_drop_nlink(inode);
 		nfs_complete_unlink(dentry, inode);
 	}
 	iput(inode);

--Sig_/Gt_xaRBbM3TLI8nbCFsrySF
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGFAwznsnt1WYoG5AQJ4gQ/+MOJkXAyaRn8svj6Tp6Jh46YVG3Eo3T4N
PR7SRlvm4VOiz73X+xTsvC0258QEOtooB9MWm0Pwt1ETcW7d4sLS7uyCwqlVOhJt
DD1IUgWXD/LJpnVQVGpUChFdwyjtphoS9T3J8Atpsx1kY5YLz9HfN48+tdqjgJaa
n3+u+vgxeS5bxIo94ujJPB9saoGBS5Ly6mreMjJ5jJ2EIulHe+1fA2NPJBeO47qn
1k2R9/629y2mJ6B7i4wwcpL6j/CET0a/35SEIWx+ngcS3zyZCuJYZGXRi3ksvU8B
zd89lCwEIW+hJhVYMfmH8kKilI0EAg6gtwL+Wl8ZrgcPOslir33IATLqDyoz+GeM
Hrwl4VcnFcRfS/0gwus2HEwB0ETNF87dyE0CxF9JEpf9TBgYQPSDKCoDDIQ78Yxu
To2r6b4aPD/8jNNP1/+jbNdiQ/fWLe2TRpIeAUHhNgHCzi9aQnIGTGzwDIitNTEz
khckuxp/TdSHgGsWGTPzxSEdTRfl7tS69Sy3bTsq76JlQIvB4R3o4WNOYIKH5Ihz
qVhfZ2RM7YMj4t+SZs8sqFXjFrJIK2O/Jqf4IFe7EkS8bj8RCksI98dM8CPevHH0
EukMl+o+y2dCqBUNhabssmjQuSm9XhVO2xX7bJoPPMBtoJW6OM//EhFuGkGlMJDj
U2hskMfN9ws=
=jxV7
-----END PGP SIGNATURE-----

--Sig_/Gt_xaRBbM3TLI8nbCFsrySF--
