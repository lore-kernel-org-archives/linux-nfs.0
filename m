Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32791 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbJYFX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Oct 2015 01:23:29 -0400
Received: by padcn9 with SMTP id cn9so733784pad.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 22:23:28 -0700 (PDT)
Subject: Re: [PATCH v7 0/4] VFS: In-kernel copy system call
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_FDF4770E-EB06-4131-BB44-A60DC879FD59"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20151024165237.GA6436@zzz>
Date: Sat, 24 Oct 2015 23:23:20 -0600
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
Message-Id: <68F5F620-B6E7-4DB7-ADFF-8FCFE7D88BEA@dilger.ca>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com> <20151024165237.GA6436@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_FDF4770E-EB06-4131-BB44-A60DC879FD59
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Oct 24, 2015, at 10:52 AM, Eric Biggers <ebiggers3@gmail.com> =
wrote:
>=20
> A few comments:
>=20
>>      if (!(file_in->f_mode & FMODE_READ) ||
>>          !(file_out->f_mode & FMODE_WRITE) ||
>>          (file_out->f_flags & O_APPEND) ||
>>          !file_out->f_op)
>>              return -EBADF;
>=20
> Isn't 'f_op' always non-NULL?
>=20
> If the destination file cannot be append-only, shouldn't this be =
documented?

Actually, wouldn't O_APPEND only be a problem if the target file wasn't
being appended to?  In other words, if the target i_size =3D=3D start =
offset
then it should be possible to use the copy syscall on an O_APPEND file.

Cheers, Andreas

>> 	if (inode_in->i_sb !=3D inode_out->i_sb ||
>> 		file_in->f_path.mnt !=3D file_out->f_path.mnt)
>> 		return -EXDEV;
>=20
> Doesn't the same mount already imply the same superblock?
>=20
>> /*
>> * copy_file_range() differs from regular file read and write in that =
it
>> * specifically allows return partial success.  When it does so is up =
to
>> * the copy_file_range method.
>> */
>=20
> What does this mean?  I thought that read() and write() can also =
return partial
> success.
>=20
>>      f_out =3D fdget(fd_out);
>>      if (!f_in.file || !f_out.file) {
>>              ret =3D -EBADF;
>>              goto out;
>> 	}
>=20
> This looked wrong at first because it may call fdput() on a 'struct =
fd' that was
> not successfully acquired, but it looks like it works currently =
because of how
> the FDPUT_FPUT flag is used.  It may be a good idea to write it the =
"obvious"
> way, though (use separate labels depending on which fdput()s need to =
happen).
>=20
>=20
> Other questions:
>=20
> Should FMODE_PREAD or FMODE_PWRITE access be checked if the user =
specifies their
> own 'off_in' or 'off_out', respectively?
>=20
> What is supposed to happen if the user passes provides a file =
descriptor to a
> non-regular file, such as a block device or char device?
>=20
> If the 'in' file has fewer than 'len' bytes remaining until EOF, what =
is the
> expected behavior?  It looks like the btrfs implementation has =
different
> behavior from the pagecache implementation.
>=20
> It appears the btrfs implementation has alignment restrictions --- =
where is this
> documented and how will users know what alignment to use?
>=20
> Are copies within the same file permitted and can the ranges overlap?  =
The man
> page doesn't say.
>=20
> It looks like the initial patch defines __NR_copy_file_range for the =
ARM
> architecture but doesn't actually hook that system call up for ARM; =
why is that?
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_FDF4770E-EB06-4131-BB44-A60DC879FD59
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVixnSXKl2rkXzB/gAQhHrQ//ZLGJo1eiwLC3Vgk5UM/ZqkUnJARB3sjJ
dbqmVM/LumCwthwL4638B04pv2CKKLbPsrroYBnoFNaNB9m3EDnEWwqu7ssd0Vn/
QMqZhxwUOxLmfBpQCQ+c1ZSJTlBrmTcVrH0BJTGnqOIxGMgLTXNSefGSl6Re2SEf
CQ/MznfK8h0CdHD3sOYEkYj32tIf6dmg3zdNcvDY+3UXQrQ2Z0iiK3cQp2kbSo1k
VLQ4o5krGF3UuSkcaLlrH0kB/0gLare1r6vXsQgyvMr36+LZZseN63jIVG8ZdnNh
dGiGoNuoVcDoLzTQJg2pdZgMyr2+fAKwjTngWJN7dqhWI9iOnIayR0qFVdSqW8Q6
Yhy2MI6vq0TxyW7VBT8PtBpnwnk3Gc4Ga4iudDSkqcd+c++riwDDNpoxrKTf+5R6
ii6ZpHQ1EHYpk2WKqVEbv4Nzyavkn3EJZoaDrMTbiORxPSQmY3m1zgTLhfGoFOvs
UrxjEWqLa7HQ13m2bl33Sgsl7HGR2lEaEbyY8wvnlR8wZUvAvGcSpOvMpqR0t/WR
MIZ4OJulFxaAy3HM3gBkrBrYEhKc2u31f1GzolaaDQsYYhuAKnRYtG7ZSyIsX3Vp
0UrYkw7WVykx5k0IcX0DCTuwLTc11fUpsXFybrLJMpeF+SK/uLdYscQPOtVoIBTL
KMb0tkG1YtY=
=XODZ
-----END PGP SIGNATURE-----

--Apple-Mail=_FDF4770E-EB06-4131-BB44-A60DC879FD59--
