Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53062 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753448AbdHUBgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 20 Aug 2017 21:36:08 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>
Date: Mon, 21 Aug 2017 11:35:57 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/8] NFS: flush out dirty data on file fput().
In-Reply-To: <1503106038.10673.11.camel@primarydata.com>
References: <150304014011.30218.1636255532744321171.stgit@noble> <150304037195.30218.15740287358704674869.stgit@noble> <1503083704.11511.9.camel@primarydata.com> <87ziawl698.fsf@notabene.neil.brown.name> <1503106038.10673.11.camel@primarydata.com>
Message-ID: <87r2w5ln2a.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 19 2017, Trond Myklebust wrote:

> On Sat, 2017-08-19 at 11:02 +1000, NeilBrown wrote:
>> On Fri, Aug 18 2017, Trond Myklebust wrote:
>>=20
>> > On Fri, 2017-08-18 at 17:12 +1000, NeilBrown wrote:
>> > > Any dirty NFS page holds an s_active reference on the superblock,
>> > > because page_private() references an nfs_page, which references
>> > > an
>> > > open context, which references the superblock.
>> > >=20
>> > > So if there are any dirty pages when the filesystem is unmounted,
>> > > the
>> > > unmount will act like a "lazy" unmount and not call ->kill_sb().
>> > > Background write-back can then write out the pages *after* the
>> > > filesystem
>> > > unmount has apparently completed.
>> > >=20
>> > > This contrasts with other filesystems which do not hold extra
>> > > s_active
>> > > references, so ->kill_sb() is reliably called on unmount, and
>> > > generic_shutdown_super() will call sync_filesystem() to flush
>> > > everything out before the unmount completes.
>> > >=20
>> > > When open/write/close is used to modify files, the final close
>> > > causes
>> > > f_op->flush to be called, which flushes all dirty pages.  However
>> > > if
>> > > open/mmap/close/modify-memory/unmap is used, dirty pages can
>> > > remain
>> > > in
>> > > memory after the application has dropped all references to the
>> > > file.
>> > > Similarly if a loop-mount is done with a NFS file, there is no
>> > > final
>> > > flush when the loop device is destroyed and the file can have
>> > > dirty
>> > > data after the last "close".
>> > >=20
>> > > Also, a loop-back mount of a device does not "close" the file
>> > > when
>> > > the
>> > > loop device is destroyed.  This can leave dirty page cache pages
>> > > too.
>> > >=20
>> > > Fix this by calling vfs_fsync() in nfs_file_release (aka
>> > > f_op->release()).  This means that on the final unmap of a file
>> > > (or
>> > > destruction of a loop device), all changes are flushed, and
>> > > ensures
>> > > that
>> > > when unmount is requested there will be no dirty pages to delay
>> > > the
>> > > final unmount.
>> > >=20
>> > > Without this patch, it is not safe to stop or disconnect the NFS
>> > > server after all clients have unmounted.  They need to unmount
>> > > and
>> > > call "sync".
>> > >=20
>> > > Signed-off-by: NeilBrown <neilb@suse.com>
>> > > ---
>> > >  fs/nfs/file.c |    6 ++++++
>> > >  1 file changed, 6 insertions(+)
>> > >=20
>> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> > > index af330c31f627..aa883d8b24e6 100644
>> > > --- a/fs/nfs/file.c
>> > > +++ b/fs/nfs/file.c
>> > > @@ -81,6 +81,12 @@ nfs_file_release(struct inode *inode, struct
>> > > file
>> > > *filp)
>> > >  {
>> > >  	dprintk("NFS: release(%pD2)\n", filp);
>> > >=20=20
>> > > +	if (filp->f_mode & FMODE_WRITE)
>> > > +		/* Ensure dirty mmapped pages are flushed
>> > > +		 * so there will be no dirty pages to
>> > > +		 * prevent an unmount from completing.
>> > > +		 */
>> > > +		vfs_fsync(filp, 0);
>> > >  	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
>> > >  	nfs_file_clear_open_context(filp);
>> > >  	return 0;
>> >=20
>> > The right fix here is to ensure that umount() flushes the dirty
>> > data,
>> > and that it aborts the umount attempt if the flush fails.
>> > Otherwise, a
>> > signal to the above fsync call will cause the problem to reoccur.
>>=20
>> The only way to ensure that umount flushes dirty data is to revert
>> commit 1daef0a86837 ("NFS: Clean up nfs_sb_active/nfs_sb_deactive").
>> As long as we are taking extra references to s_active, umount won't
>> do
>> what it ought to do.
>>=20
>
> Reverting that patch is not sufficient. You'd still need to call
> sync_filesystem(), and abort the umount if the latter fails.

generic_shutdown_super() (which nfs_kill_super() calls) already calls
sync_filesystem().  However sync_filesystem() cannot fail - it just
asks bdi workers to flush data out, then waits for completion.

If the server is working, this should complete correctly.  If it isn't
this will block indefinitely in the same way that a "sync" following the
umount will block indefinitely today.

So while I agree that reverting this isn't sufficient, I think it might
be a step in the right direction.

I've been experimenting with what happens when the server does down and
you try to unmount.  With NFSv4, the state manager can still be trying
to send a RENEW and not want to let go until it gets an answer.  I
haven't traced it all through yet to understand why or how significant
this is.


>
>> I do wonder what we should do when you try to unmount a filesystem
>> mounted from an inaccessible server.
>> Blocking is awkward for scripts to work with.  Failing with EBUSY
>> might
>> be misleading.
>> I don't think that using MNT_FORCE guarantees success does it?  It
>> would
>> need to discard any dirty data and abort any other background tasks.
>
> MNT_FORCE will only abort any outstanding RPC calls. It is constrained
> by the fact that we don't serialise umount and mount, and that the
> filesystem on which we are operating may be mounted in several places
> in the main namespace and indeed in several private namespaces to
> boot.

Yes, that is a problem.
If we could arrange that SIGKILL *always* kills the process so that it
drops the reference to the filesystem, we could possible delay the
MNT_FORCE handling until deactivate_super(), but at present we sometimes
need MNT_FORCE to allow KILLed processes to die, and while there are
processes with file descriptors, umount will not get as far as
deactivate_super().
(We need filemap_fdatawait_range() to be killable to do better.)

>
>> I think I would be in favor of EBUSY rather than a hang, and of
>> making
>> MNT_FORCE a silver bullet providing there are no open file
>> descriptors
>> on the filesystem.
>
> All other filesystems trigger sync_filesystem(), and that's what the
> VFS expects us to do. The problem is the VFS assumes that call will
> always succeed, and won't ever return an error.

Yes, it is not easy to find an "ideal" solution.

Given that fact, and given that the present patch does address an easily
demonstrated symptom, would you accept it as a small step in a good
direction?  When the server is still accessible, and when no-one kills
processes at awkward times, it definitely helps.

Even with a SIGKILL, I think the WRITEs and the COMMIT will be sent, but
the COMMIT won't be waited for...

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmaOP8ACgkQOeye3VZi
gbl+9g//SnStEXTazQUvLaGeEGUeoNNaCturqQTN1QyFKkrWVpicunKCpmFQDpMG
qu4J5xhMvTYGiEQCBKtfWoMLqPAfNmjTSC5xuXCxYMQMAMifBLnFxJwzeO844tp2
MlWvhcWbCYg/tGGSlaBSOqrZFddkhjKr1tQv7HeQRMmxkRQtIL3BtL5KKDPxOrMY
e0NMmGPNMHVRtb4XZimJDTYwQzbXZ1lEr7WtuvXF8VbJ+oB4mus62f91KSdYmduZ
ZoppW1DxwFy26LcuK3s9IgTURc6X1CjfVb8Sdzo+CbYMGulAQrI/yVBSd/dnNA7z
E2d9SW8kUJDB632VTy5ZAZ45dca6IVdwl/8cwMk8WIl3AO1GJpzb+TvWklh6xx7S
6dZjMLiQkC/UahP+1mWOp98bPSoOgNUShRQD/PvCEbCINQ5g9BRsNUHAKyOEj7Ed
bVT/6UyN90wbDr1er7r/oNK61cWKTtbr8/6Tkx/pL4HCvd9tZ2QXbaPg2aDr1VDU
Td28ZIT5cbWsyg7eODz7l+ajzm85htoq4SjrrR16pahOpp5DM8y+SeqNbg6mXHbW
x6HnqZRBeSX743gyD0voiOk1RCnwcx+pCVnqeMlspTJ6OnKKny4MZbaolonPs4wc
itYR6fVEH/dOwHETmkeuLbMxB1LD+WV8657wb+JfJNwTWOCdHqU=
=TMXH
-----END PGP SIGNATURE-----
--=-=-=--
