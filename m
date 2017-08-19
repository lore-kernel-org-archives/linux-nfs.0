Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52549 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751017AbdHSBCU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 21:02:20 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>
Date: Sat, 19 Aug 2017 11:02:11 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/8] NFS: flush out dirty data on file fput().
In-Reply-To: <1503083704.11511.9.camel@primarydata.com>
References: <150304014011.30218.1636255532744321171.stgit@noble> <150304037195.30218.15740287358704674869.stgit@noble> <1503083704.11511.9.camel@primarydata.com>
Message-ID: <87ziawl698.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 18 2017, Trond Myklebust wrote:

> On Fri, 2017-08-18 at 17:12 +1000, NeilBrown wrote:
>> Any dirty NFS page holds an s_active reference on the superblock,
>> because page_private() references an nfs_page, which references an
>> open context, which references the superblock.
>>=20
>> So if there are any dirty pages when the filesystem is unmounted, the
>> unmount will act like a "lazy" unmount and not call ->kill_sb().
>> Background write-back can then write out the pages *after* the
>> filesystem
>> unmount has apparently completed.
>>=20
>> This contrasts with other filesystems which do not hold extra
>> s_active
>> references, so ->kill_sb() is reliably called on unmount, and
>> generic_shutdown_super() will call sync_filesystem() to flush
>> everything out before the unmount completes.
>>=20
>> When open/write/close is used to modify files, the final close causes
>> f_op->flush to be called, which flushes all dirty pages.  However if
>> open/mmap/close/modify-memory/unmap is used, dirty pages can remain
>> in
>> memory after the application has dropped all references to the file.
>> Similarly if a loop-mount is done with a NFS file, there is no final
>> flush when the loop device is destroyed and the file can have dirty
>> data after the last "close".
>>=20
>> Also, a loop-back mount of a device does not "close" the file when
>> the
>> loop device is destroyed.  This can leave dirty page cache pages too.
>>=20
>> Fix this by calling vfs_fsync() in nfs_file_release (aka
>> f_op->release()).  This means that on the final unmap of a file (or
>> destruction of a loop device), all changes are flushed, and ensures
>> that
>> when unmount is requested there will be no dirty pages to delay the
>> final unmount.
>>=20
>> Without this patch, it is not safe to stop or disconnect the NFS
>> server after all clients have unmounted.  They need to unmount and
>> call "sync".
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfs/file.c |    6 ++++++
>>  1 file changed, 6 insertions(+)
>>=20
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index af330c31f627..aa883d8b24e6 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -81,6 +81,12 @@ nfs_file_release(struct inode *inode, struct file
>> *filp)
>>  {
>>  	dprintk("NFS: release(%pD2)\n", filp);
>>=20=20
>> +	if (filp->f_mode & FMODE_WRITE)
>> +		/* Ensure dirty mmapped pages are flushed
>> +		 * so there will be no dirty pages to
>> +		 * prevent an unmount from completing.
>> +		 */
>> +		vfs_fsync(filp, 0);
>>  	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
>>  	nfs_file_clear_open_context(filp);
>>  	return 0;
>
> The right fix here is to ensure that umount() flushes the dirty data,
> and that it aborts the umount attempt if the flush fails. Otherwise, a
> signal to the above fsync call will cause the problem to reoccur.

The only way to ensure that umount flushes dirty data is to revert
commit 1daef0a86837 ("NFS: Clean up nfs_sb_active/nfs_sb_deactive").
As long as we are taking extra references to s_active, umount won't do
what it ought to do.

I do wonder what we should do when you try to unmount a filesystem
mounted from an inaccessible server.
Blocking is awkward for scripts to work with.  Failing with EBUSY might
be misleading.
I don't think that using MNT_FORCE guarantees success does it?  It would
need to discard any dirty data and abort any other background tasks.

I think I would be in favor of EBUSY rather than a hang, and of making
MNT_FORCE a silver bullet providing there are no open file descriptors
on the filesystem.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmXjhUACgkQOeye3VZi
gbnK4A/+PIP1dFfniz9/QJLr/atQGw8Idjs8wThaT75JYnL/3jcA9TY15rRzqvsK
rOFBM0wbH1oG8VSfixfQdNJPD2JPjZMoK9XN8hHk6ALqipMihPOPbrdFIXSRjBag
k4DU6qa8W67oLpLOoDxhNo2GLuKO8UGxyDzTGI3gJ0gvdnLqTWYlBDpS9DHa26hC
Do5KXoOgseAoMts42qTSkIJshcbu2BORA57d6p80KpDyV370SvRTRkq3Ioc/sRen
MeCXmXONnUTIfrVfcBfW2mamV++d+d8RUD2htiGm/xjc7fhGnroth3xzDgaISw3l
/SLpur/5M0YRHgxDo/zyj5pP7xnRhT0QVSEmSfVcofDmN9SaRo9c+xFMpTr9HBM1
FpqcnSjHkQzH1TzGyRtFwNgt9FGeS9kwHKPIO7m9IDrlSb8mo8Vpj5htuuxJYh+Q
gM3mrrfVn71bcJJQX8/DK12cB8k/ZJjAfvLWtS9TfrkwiyWMQDBqEm0rD9D7PYnN
f3hv2I+wIAXuYvFb1y0GQTrqbfbNFUxRRzaRnUKON/FYi/KsSFFgOpkTPS2Yxdk5
bK2ULS+Vkz3OjIuLtAivLrxg08KjUsHOz8ijaT+7kXb858OITHoz5UjB2N148NQh
UpcVmD5kA7ZOr4U467VXKPjW9fknUOY45gtQtK95uc0M2sGfy2k=
=N9GH
-----END PGP SIGNATURE-----
--=-=-=--
