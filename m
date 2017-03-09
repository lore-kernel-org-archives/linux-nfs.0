Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54041 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750803AbdCIVi4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 16:38:56 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 10 Mar 2017 08:38:00 +1100
Subject: Re: A NFS mount can still write to the server after 'umount' has completed.
In-Reply-To: <1489065706.3121.1.camel@primarydata.com>
References: <871su7i0iw.fsf@notabene.neil.brown.name> <87y3wfgipy.fsf@notabene.neil.brown.name> <1489065706.3121.1.camel@primarydata.com>
Message-ID: <87pohqgmh3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 09 2017, Trond Myklebust wrote:

> On Thu, 2017-03-09 at 15:46 +1100, NeilBrown wrote:
>> On Thu, Mar 09 2017, NeilBrown wrote:
>>=20
>> > I've been chasing down a problem where a customer has a localhost
>> > mount,
>> > and the sequence
>> > =C2=A0 unmount -at nfs,nfs4
>> > =C2=A0 stop nfsserver
>> > =C2=A0 sync
>> >=20
>> > hangs on the sync.=C2=A0=C2=A0The 'sync' is trying to write to the NFS
>> > filesystem
>> > that has just been unmounted.
>
> So why can't you move the sync up one line?
>
>> > I have duplicated the problem on a current mainline kernel.
>> >=20
>> > There are two important facts that lead to the explanation of this.
>> > 1/ whenever a 'struct file' is open, an s_active reference is held
>> > on
>> > =C2=A0=C2=A0=C2=A0the superblock, via "open_context" calling nfs_sb_ac=
tive().
>> > =C2=A0=C2=A0=C2=A0This doesn't prevent "unmount" from succeeding (i.e.=
 EBUSY isn't
>> > =C2=A0=C2=A0=C2=A0returned), but does prevent the actual unmount from =
happening
>> > =C2=A0=C2=A0=C2=A0(->kill_sb() isn't called).
>> > 2/ When a memory mapping of a file is torn down, the file is
>> > =C2=A0=C2=A0=C2=A0"released", causing the context to be discarded and =
the
>> > sb_active
>> > =C2=A0=C2=A0=C2=A0reference released, but unlike close(2), file_operat=
ions-
>> > >flush()
>> > =C2=A0=C2=A0=C2=A0is not called.
>>=20
>> I realised that there is another piece of the puzzle.
>> When a page is marked dirty (e.g. nfs_vm_page_mkwrite),
>> =C2=A0nfs_updatepage() -> nfs_writepage_setup()
>> creates a 'struct nfs_page' request which holds a reference to
>> the open context, which in turn holds an active reference to the
>> superblock.
>> So as long as there are dirty pages, the superblock will not go
>> inactive.=C2=A0=C2=A0All the rest still holds.
>>=20
>> NeilBrown
>>=20
>>=20
>> >=20
>> > Consequently, if you:
>> > =C2=A0open an NFS file
>> > =C2=A0mmap some pages PROT_WRITE
>> > =C2=A0close the file
>> > =C2=A0modify the pages
>> > =C2=A0unmap the pages
>> > =C2=A0unmount the filesystem
>> >=20
>> > the filesystem will remain active, and the pages will remain dirty.
>> > If you then make the nfs server unavailable - e.g. stop it, or tear
>> > down
>> > the network connection - and then call 'sync', the sync will hang.
>> >=20
>> > This is surprising, at the least :-)
>> >=20
>> > I have two ideas how it might be fixed.
>> >=20
>> > One is to call nfs_file_flush() from within nfs_file_release().
>> > This is probably simplest (and appears to work).
>> >=20
>> > The other is to add a ".close" to nfs_file_vm_ops.=C2=A0=C2=A0This cou=
ld
>> > trigger a
>> > (partial) flush whenever a page is unmapped.=C2=A0=C2=A0As closing an =
NFS
>> > file
>> > always triggers a flush, it seems reasonable that unmapping a page
>> > would trigger a flush of that page.
>> >=20
>> > Thoughts?
>> >=20
>
> All this is working as expected. The only way to ensure that data is
> synced to disk by mmap() is to explicitly call msync(). This is well
> documented, and should be well understood by application developers. If
> those developers are ignoring the documentation, then I suggest votoing
> with your feet and getting your software from someone else.=20

Hi Trond,
 I don't understand how you can see this behaviour as acceptable.
 For any other filesystem, unmount is a synchronisation point.
 Assuming there are not bind mount or similar, and that MNT_DETACH is
 not used, an unmount will flush out any changes.  It doesn't matter whether
 or not the application has called fsync or msync - the flush still
 happens on unmount.
 So with any other filesystem you can unmount and then remove the media
 and be sure that nothing is consistent and that no further writes will
 be attempted.
 With NFS as it currently is, unmount does not act as a synchronisation
 point, and writes can continue after the unmount.  How is that
 acceptable?

 The patch below explains the problem and provides a simple fix.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Fri, 10 Mar 2017 08:19:32 +1100
Subject: [PATCH] NFS: flush out dirty data on final fput().

Any dirty NFS page holds an s_active reference on the superblock,
because page_private() references an nfs_page, which references an
open context, which references the superblock.

So if there are any dirty pages when the filesystem is unmounted, the
unmount will act like a "lazy" unmount and not call ->kill_sb().
Background write-back can then write out the pages *after* the filesystem
unmount has apparently completed.

This contrasts with other filesystems which do not hold extra s_active
references, so ->kill_sb() is reliably called on unmount, and
generic_shutdown_super() will call sync_filesystem() to flush
everything out before the unmount completes.

When open/write/close is used to modify files, the final close causes
f_op->flush to be called, which flushes all dirty pages.  However if
open/mmap/close/modify-memory/unmap is used, dirty pages can remain in
memory after the application has dropped all references to the file.

Fix this by calling vfs_fsync() in nfs_file_release (aka
f_op->release()).  This means that on the final unmap of a file, all
changes are flushed, and ensures that when unmount is requested there
will be no dirty pages to delay the final unmount.

Without this patch, it is not safe to stop or disconnect the NFS
server after all clients have unmounted.  They need to unmount and
call "sync".

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/file.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 668213984d68..d20cf9b3019b 100644
=2D-- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -81,6 +81,12 @@ nfs_file_release(struct inode *inode, struct file *filp)
 {
 	dprintk("NFS: release(%pD2)\n", filp);
=20
+	if (filp->f_mode & FMODE_WRITE)
+		/* Ensure dirty mmapped pages are flushed
+		 * so there will be no dirty pages to
+		 * prevent an unmount from completing.
+		 */
+		vfs_fsync(filp, 0);
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	nfs_file_clear_open_context(filp);
 	return 0;
=2D-=20
2.12.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljByzgACgkQOeye3VZi
gbkFRA//ckwHme4Cnv4siFfZmtL3wFieoHVYDqDzlBfXJoOhsr43ac2+cRXMr6ss
aMj6MebZzCT12QFk85RLgLU3Y+3Es1XnPP2b9qMm2pIEBSfyn618HaCYyFTD4Lzv
eEEkGm65qsE9JUB4E5Nbf2pZCArwD/8y9/wR5w+zU/j0uFzTbwHxewEP8Fu8WHIX
BRJDZHqEbjzznTNUSFrR4NK2OOlHZjyTBc6fe2po+45XBHIWFx8CbwQdUnzi7VN6
pX/y4zCvl+lOg2bo8jjPw4XeRdTI51GHvHdP50rknczJ4rMayCmEF9iMgFsiyuRu
N53cmYBF28hXSofC8y6+huOntmDUdluCctGXszJnDeR9EiWKqY+yffVg5aBZNTVL
i1nA2KDESwZWZf5KG65QutjUKf9Sim7bzLAm4xuMGOoCIKTzg+gguuqcJKTUWp7l
dQYYO6iPJF8HcmBLKPHs5me8jeRLmZAQGaW00gChPCLdkiDJrvy4SsYZZF1OQaQN
r0UQ79hdKg9pFHjHPzERMU3UC7ITkaKTyFO53tqu3pb1RmmefOc6D3VW4K2TmqDq
Gj9If2l97AED2tc/5GyCUsvUUfEfLhmeaVaKbUuCgMOKUuX1xVFLeLHIw0b8Kg+d
3TvqArlOWnYL8xHo8r3ot17TGJv/+kdvb1L0MHLZJJVT2GXDbG4=
=Ofii
-----END PGP SIGNATURE-----
--=-=-=--
