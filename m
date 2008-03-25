From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Tue, 25 Mar 2008 09:59:58 -0700
Message-ID: <47E92F8E.7030504@m2000.com>
References: <47CF0829.4020502@m2000.com>	<1204752463.5035.34.camel@heimdal.trondhjem.org>	<47CF157B.1010908@m2000.com>	<18383.24847.381754.517731@notabene.brown>	<47CF62C5.7000908@m2000.com>	<18384.50909.866848.966192@notabene.brown>	<9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>	<20080312221511.GC31632@fieldses.org>	<9a8748490803121516u36395872i70cc88b0439adc74@mail.gmail.com>	<18394.1501.991087.80264@notabene.brown> <47DAEFD0.9020407@m2000.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig19F70A3E086D22C63DA14C33"
Cc: Jesper Juhl <jesper.juhl@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Frederic Revenu <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Jeff Doan <jdoan-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from asterix.m2000.com ([212.155.102.83]:3102 "EHLO
	asterix.m2000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbYCYRAP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2008 13:00:15 -0400
In-Reply-To: <47DAEFD0.9020407-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig19F70A3E086D22C63DA14C33
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Adam Schrotenboer wrote:
> Neil Brown wrote:
>> On Wednesday March 12, jesper.juhl@gmail.com wrote: =20
>>> On 12/03/2008, J. Bruce Fields <bfields@fieldses.org> wrote: =20
>>>> What was the exported filesystem?  =20
>>> XFS =20
>>
>> It's a bit of a long shot, but could you try mounting the XFS file
>> system with
>>    -o ikeep
>>
>> and see if it makes a difference.
>>
>> When you have "ikeep", I can find the code that increments the
>> generation number between different uses of the one inode number.
>>
>> When you have "noikeep" (which I think is the default) it doesn't keep=

>> the inode of disk when deleted and so (presumably) needs generate a
>> random generation number for each use.  But I cannot find the code
>> that does that.  I'm probably not looking in the right place, but I
>> don't think it can hurt to try "-o ikeep".
>>
>> NeilBrown
>>  =20
> Ok, I've unmounted and remounted with that option enabled=20
> (/proc/mounts confirms it's enabled). We'll see what happens.

    Well, it's been almost 2 weeks (11 days anyhow) and I am not seeing=20
the nfs_update_inode message in the syslogs of any of our compute=20
servers. I need to talk to the various people who work with them to=20
verify, but it looks like this problem has been resolved.

    Thank you very much for all of your help.


--------------enig19F70A3E086D22C63DA14C33
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH6S+RyWYDdvnGArwRAtJAAKCiuSB93MRNvg5lmdtrUUwBUIzfvACbBSMS
iIVaqueg7urwaPaW0TIywXg=
=qL8P
-----END PGP SIGNATURE-----

--------------enig19F70A3E086D22C63DA14C33--
