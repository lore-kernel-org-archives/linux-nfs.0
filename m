From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 12 Mar 2008 11:16:04 -0700
Message-ID: <47D81DE4.5040303@m2000.com>
References: <47CF0829.4020502@m2000.com>	<1204752463.5035.34.camel@heimdal.trondhjem.org>	<47CF157B.1010908@m2000.com>	<18383.24847.381754.517731@notabene.brown>	<47CF62C5.7000908@m2000.com> <18384.50909.866848.966192@notabene.brown>	<47D0D8B5.6050403@m2000.com>  <47D818FB.8080302@m2000.com> <1205345284.9419.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5BE7FD79FB07E04B58B7B750"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	jesper.juhl@gmail.com, Fred Revenu <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from asterix.m2000.com ([212.155.102.83]:3106 "EHLO
	asterix.m2000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbYCLSQQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2008 14:16:16 -0400
In-Reply-To: <1205345284.9419.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5BE7FD79FB07E04B58B7B750
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Trond Myklebust wrote:
> On Wed, 2008-03-12 at 10:55 -0700, Adam Schrotenboer wrote:
>  =20
>> Another excerpt from last night.
>>
>> Mar 12 00:53:16 wanda kernel: nfs: server 192.168.1.27 not responding,=
=20
>> still trying
>> Mar 12 00:53:18 wanda kernel: nfs: server 192.168.1.27 OK
>> Mar 12 00:54:29 wanda kernel: nfs_update_inode: inode 1075049148 mode =

>> changed, 0040755 to 0100644
>>    =20
>
> Hang on. That does not look like an XID collision problem...
>
> That code path basically means that the fileids/inode numbers match,
> which would not be the case if we were talking about an XID collision
> causing the reply cache to replay an old request...
>
> That message rather symptomatic of a filehandle reuse problem. In other=

> words a NFS filehandle appears to be reused to label a regular file
> after it has been used for a directory with the same fileid/inode
> number. That is a definite server bug.
>
> Are you sure that you are using the regular kernel nfs server?
>
>  =20
Quite. OpenSuSE 10.2 stock unmodified kernel.

dolphin:~ # uname -a
Linux dolphin 2.6.18.2-34-default #1 SMP Mon Nov 27 11:46:27 UTC 2006=20
x86_64 x86_64 x86_64 GNU/Linux

dolphin:~ # top -bn1 |grep nfsd


  PID  PPID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAN=
D
 3916     1 root      15   0     0    0    0 S    0  0.0   3:04.42 nfsd
 3942     1 root      15   0     0    0    0 S    0  0.0   3:11.88 nfsd
(there's quite a bit more of these threads than this (32), but they all=20
look the same in top or ps)



--------------enig5BE7FD79FB07E04B58B7B750
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH2B3kyWYDdvnGArwRAm4XAJ9KOX7o3+qns7jvH04eiXOWCxTyIQCfZHTN
Qo7L6AtD7GzZyDVFRjZNxJU=
=4eHi
-----END PGP SIGNATURE-----

--------------enig5BE7FD79FB07E04B58B7B750--
