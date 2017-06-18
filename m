Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44681 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750824AbdFREa3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Jun 2017 00:30:29 -0400
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 18 Jun 2017 14:30:18 +1000
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] loop: use filp_close() rather than fput()
In-Reply-To: <20170617000157.GQ31671@ZenIV.linux.org.uk>
References: <149758925866.10006.12779875832895865043.stgit@noble> <149758932908.10006.10765671892098302463.stgit@noble> <20170617000157.GQ31671@ZenIV.linux.org.uk>
Message-ID: <87efuh6hph.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 17 2017, Al Viro wrote:

> On Fri, Jun 16, 2017 at 03:02:09PM +1000, NeilBrown wrote:
>> When a loop device is being shutdown the backing file is
>> closed with fput().  This is different from how close(2)
>> closes files - it uses filp_close().
>>=20
>> The difference is important for filesystems which provide a ->flush
>> file operation such as NFS.  NFS assumes a flush will always
>> be called on last close, and gets confused otherwise.
>
> Huh?  You do realize that mmap() + close() + modify + msync() + munmap()
> will have IO done *after* the last flush, right?

Yes I do ... or rather I did.  I didn't make that connection this time.

The sequence you describe causes exactly the same sort of problem.
I sent a patch to Trond to add a vfs_fsync() call to nfs_file_release()
but he claims the current behaviour is "working as expected".  I didn't
quite know what to make of that..

https://www.spinics.net/lists/linux-nfs/msg62603.html

To provide the full picture:
 When an NFS file has dirty pages, they (indirectly) hold extra
 references on the superblock, using nfs_sb_active().
 This means that when the filesystem is unmounted, the superblock
 remains active until all the writes complete.  This contrasts with
 every other filesystems where all writes will complete before the
 umount returns.

 When you open/write/close, there will be no dirty pages at umount time
 (because close() flushes) so this doesn't cause a problem.  But when
 you mmap, or use a loop device, then dirty pages can still be around to
 keep the superblock alive.

 The observable symptom that brought this to my attention was that
    umount -a -t nfs
    disable network
    sync

 can hang in sync, because the NFS filesystems can still be waiting to
 write out data.

If nfs_file_release() adds vfs_fsync(), or maybe if __fput() calls
filp->f_op->flush(), then loop.c wouldn't need to use filp_close().

Which would you prefer?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllGAdwACgkQOeye3VZi
gbkbsA//WZua4t3iS2Uwmvt0OPDoWUsDw2BWw27KBRHADEe/H9Zju+55HGt/3qDs
3Qp3GUUbXfwV/OyjkOKc8UkkPvaok/2RJiEOm5dW7Zekcq9I3pByERZPQgAaWUSA
GVGcFBZ775woKxjfH7nLI722OqUb68U7sJk0HvabHv7U1D8zti7mvRMxCM3rVASg
l5/I9QYx/cE3i+da7+rZC3BF1+heoycUc6zVzp7gZQcfSlvVDND+UM91B8dpDe/9
JsFKNH+vCVC4inHEZbB9DgmNuQFY4sj6YLi7CzDwR7jzxRKOVF8y3divwvImunll
SAbsuSwhKwd6MPfZFKHAKK6WIIMf7yj/aomjIKATatly8ae8F663atX/xPGkKYsG
HWK2zC1NHTLdDPBqV+BtGUd1NS2ZsUo1/O1OkLi/nFh66dXg7UQbcDkKOM8Wi1qA
qaER74xVm85dlueMjlxS7VRNssWq2cj+CF2JGbGlQETctBctEEcF2/xBbzpPRJnG
FNZHLd7376loCV6k9Foa5m/zoR7RSRCtSmHEkU40m/aivcywNTY04tTkJjTq5S+/
V1ByTct2ZDjjjy0+5dCGUe8HyL1bq5n+pr50kwxaScpUNUKZWMiPPLURjMhJLzwo
Ga/1uLdkTJViOuhRsrz6BWjYRLGmzJPw3e04YFjjo157/qKtWyY=
=2tB4
-----END PGP SIGNATURE-----
--=-=-=--
