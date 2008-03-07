From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Thu, 06 Mar 2008 21:55:01 -0800
Message-ID: <47D0D8B5.6050403@m2000.com>
References: <47CF0829.4020502@m2000.com>	<1204752463.5035.34.camel@heimdal.trondhjem.org>	<47CF157B.1010908@m2000.com>	<18383.24847.381754.517731@notabene.brown>	<47CF62C5.7000908@m2000.com> <18384.50909.866848.966192@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig8E8E5A3EA856F8C2464125AC"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>, jesper.juhl@gmail.com
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.ldmi.net ([64.118.147.197]:35240 "EHLO mail.ldmi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751373AbYCGFzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 00:55:10 -0500
In-Reply-To: <18384.50909.866848.966192-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8E8E5A3EA856F8C2464125AC
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Neil Brown wrote:
> On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
>  =20
>> Neil Brown wrote:
>>    =20
>>> On Wednesday March 5, adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org wrote:
>>>  =20
>>> Where :-)
>>>
>>> A excerpt from the logs to show actual error messages could be
>>> helpful.
>>>
>>> Thanks,
>>> NeilBrown
>>>      =20
>> sorry, must have missed the paste
>>
>> Feb 28 17:27:58 koi kernel: nfs_update_inode: inode 3221350147 mode=20
>> changed, 0040755 to 0100644
>> Feb 28 21:57:22 koi kernel: nfs_update_inode: inode 2149056279 mode=20
>> changed, 0040755 to 0100755
>> Mar  5 01:43:21 koi kernel: nfs_update_inode: inode 3222473680 mode=20
>> changed, 0040755 to 0100644
>> Mar  5 08:52:19 koi kernel: nfs_update_inode: inode 3222473568 mode=20
>> changed, 0120777 to 0100644
>> Mar  5 15:00:01 koi kernel: nfs_update_inode: inode 3222473569 mode=20
>> changed, 0120777 to 0100644
>> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473674 mode=20
>> changed, 0120777 to 0100644
>> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473675 mode=20
>> changed, 0120777 to 0100644
>> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473672 mode=20
>> changed, 0040755 to 0100644
>> Mar  5 15:00:31 koi kernel: nfs_update_inode: inode 3222473673 mode=20
>> changed, 0120777 to 0100644
>>
>>
>>    =20
> Hmmm...
> Directories and symlinks "changing" to regular files.
>
> 32bit inode numbers with the high bit set.
>
> Random times, but a burst at 3pm one afternoon.
>
> The fact that it happens so rarely make is very hard to collect more
> data....
>
>
> What happens when a user experiences an error?=20
well, sometimes it shows up as a read/write error (that is the error=20
code returned by the application).
SVN tend to be more verbose (although I have no examples)
>  What sort of file is
> the error reported against? =20
It does not to my knowledge only happen to certain classes of files,=20
although it does seem to happen most often when lots of files are being=20
created.
> Does the file remain inaccessible or does
> it start working again soon? =20
No data, maybe Thomas knows something.
> Is the same file accessible from another
> client?
>  =20
No data, esp as it never happens to me personally.
> NeilBrown
>  =20



--------------enig8E8E5A3EA856F8C2464125AC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH0Ni1yWYDdvnGArwRA0dRAKCTWA66+XeHuyv5TGOnE3pN/BJlGACdE/kB
jd/KWte/x/AV6ejLWV07FIM=
=BDqG
-----END PGP SIGNATURE-----

--------------enig8E8E5A3EA856F8C2464125AC--
