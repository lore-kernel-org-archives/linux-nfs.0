Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771Ab2IYKWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 06:22:02 -0400
Date: Tue, 25 Sep 2012 06:21:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
Message-ID: <20120925062155.57360ee2@tlielax.poochiereds.net>
In-Reply-To: <20120925152731.52528dca@notabene.brown>
References: <20120829162527.GA3635@NickAndBarb.net>
	<20120829151641.20cde4bc@corrin.poochiereds.net>
	<20120925152731.52528dca@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aeYNxA1nSwnQnXAtu+TfonA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aeYNxA1nSwnQnXAtu+TfonA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Sep 2012 15:27:31 +1000
NeilBrown <neilb@suse.de> wrote:

> On Wed, 29 Aug 2012 15:16:41 -0700 Jeff Layton <jlayton@redhat.com> wrote:
>=20
>=20
> > This stack trace comes from cifs, not nfs.
>=20
> It's quite easy to trigger on NFS too.
>=20
>  mount server:/path /mnt; exec 3>& /mnt/foo ; rm /mnt/foo; rm /mnt/.nfs* ;
>  exec 3>&-
>=20
> [634155.004438] WARNING:
> at /home/abuild/rpmbuild/BUILD/kernel-desktop-3.5.0/lin [634155.004442]
> Hardware name: Latitude E6510 [634155.004577]  crc_itu_t crc32c_intel
> snd_hwdep snd_pcm snd_timer snd soundcor [634155.004609] Pid: 13402, comm:
> bash Tainted: G        W    3.5.0-36-desktop # [634155.004611] Call Trace:
> [634155.004630]  [<ffffffff8100444a>] dump_trace+0xaa/0x2b0
> [634155.004641]  [<ffffffff815a23dc>] dump_stack+0x69/0x6f
> [634155.004653]  [<ffffffff81041a0b>] warn_slowpath_common+0x7b/0xc0
> [634155.004662]  [<ffffffff811832e4>] drop_nlink+0x34/0x40
> [634155.004687]  [<ffffffffa05bb6c3>] nfs_dentry_iput+0x33/0x70 [nfs]
> [634155.004714]  [<ffffffff8118049e>] dput+0x12e/0x230
> [634155.004726]  [<ffffffff8116b230>] __fput+0x170/0x230
> [634155.004735]  [<ffffffff81167c0f>] filp_close+0x5f/0x90
> [634155.004743]  [<ffffffff81167cd7>] sys_close+0x97/0x100
> [634155.004754]  [<ffffffff815c3b39>] system_call_fastpath+0x16/0x1b
> [634155.004767]  [<00007f2a73a0d110>] 0x7f2a73a0d10f
>=20
> Is this suitable for -stable?  It seems like it is just a harmless warnin=
g.
>=20
> NeilBrown
>=20
>=20
> Subject: NFS: avoid warning from nfs_drop_nlink
>=20
> If you remove a file which is open, NFS will 'silly-rename' it to a
> hidden file.
> If you then remove that hidden file, and then close the open file,
> then nfs_dentry_iput will perform an extra drop_nlink().
> Since 3.3-rc1, this has produced a warning.
> The simplest way to suppress it is to use "nfs_drop_nlink" which
> checks for i_nlink being zero.
>=20
> Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 627f108..268af03 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1174,7 +1174,7 @@ static void nfs_dentry_iput(struct dentry *dentry,
> struct inode *inode) NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_DA=
TA;
> =20
>  	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
> -		drop_nlink(inode);
> +		nfs_drop_nlink(inode);
>  		nfs_complete_unlink(dentry, inode);
>  	}
>  	iput(inode);

That looks reasonable to me. I agree that it's a harmless warning but
it looks scary to users...

Just for the sake of argument though, I wonder whether NFS or CIFS has
any business manipulating the nlink count like this. It seems like it's
possible to end up with these manipulations racing with attribute
updates.

Would it make more sense to replace these drop_nlink calls with a call
to mark the attributes as invalid? We would need to come up with a new
way to deal with drop_inode however...

In any case, you can add this to the patch above if you like:

Reviewed-by: Jeff Layton <jlayton@redhat.com>

--Sig_/aeYNxA1nSwnQnXAtu+TfonA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIcBAEBAgAGBQJQYYXDAAoJEAAOaEEZVoIVrxIQAMVPVKc3vXIu21QZYzQ4/6Ha
5yf4tEIVvwrJTzHoptmsBlvtR5n0L4pkS+hOU+O837NIfvoop9E0D4dRqKCZ8Jeh
3ONSRkrK9BF5sBqCvVhbDoCvuyFkCM16SUyIjyGUomOLeZRqzfnsHqO3/nwf6XwB
RBeZ4BHfRZb9pdGw9eC5hJJez5iDi7APQEhu+2y1WKASYcBr/od6Bb4qqbNWXac+
ik5pA6ujK/5xkSwWdDTnjQkOE0RPDDMTB2pouDDTx41EbB36yxz4/M12rFfVIWS7
0uaCVHLopcO753aUjpWZzwrlTG64BDmgQhQpTyc4g2jHGRxeXiCuCANrSp5spiAf
n/66S5juITSxTszdY9nLx/+n1yBzVgQcN4o97iZprLU/m5uva2XeMW/VCJpcRhc8
7wAwconHKPh1W63rE8qOUMDSDGnJ1z5eP8UnKnMkdWZMxBtaxXMVCO35CQScis2I
svWG2ubYMrAy6POYuBBLq2NLzOZpF7g8d/91qaIoTFDZZdbN4aQrDhQaPgQ2pO0d
e1+YTYAFnMMaXP/lqxU179ll5vmRE4Hbtgc7YE53EKzNB9BPUMqfRV6Il8JP7mVe
GVXf2e4aCG4c6odA23TuXMuFefgjiqa+qX+xJJ9o+r/Mh8+fuVjoAbkHbXyJovr+
B9BERV1W+mdM+J35HlkA
=1uo2
-----END PGP SIGNATURE-----

--Sig_/aeYNxA1nSwnQnXAtu+TfonA--
