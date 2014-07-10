Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56867 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbaGJFLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 01:11:18 -0400
Date: Thu, 10 Jul 2014 15:11:12 +1000
From: NeilBrown <neilb@suse.de>
To: Nathan Shearer <mail@nathanshearer.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: umount -f stalls forever
Message-ID: <20140710151112.7710bb7b@notabene.brown>
In-Reply-To: <53BDA2C7.4030007@nathanshearer.ca>
References: <53BDA2C7.4030007@nathanshearer.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Z9XLYwSFP15WBzk8k4Nt3kg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Z9XLYwSFP15WBzk8k4Nt3kg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 09 Jul 2014 14:15:03 -0600 Nathan Shearer <mail@nathanshearer.ca>
wrote:

> When I have an nfs share that is mounted with the hard option (either
> explicitly or implicitly since hard is on by default), and the nfs
> server becomes unresponsive for any reason, it often causes the entire
> OS to hang on many operations. In some cases I cannot even reboot a
> server depending on what the nfs share was used for.
>=20
> I relaize that this was probably done intentionally to prevent data
> loss. However, when I am cleaning up a disaster and I actually do want
> to "umount -f" a stalled nfs share and data loss es acceptable, then I
> expect that command to return and the share to be unmounted. From a
> usability perspective, stalling forever when I am explicitly forcing an
> action is not right.
>=20
> There is a workaround: and that is to assign the IP of the nfs server to
> my system then issue umount -f, however that hardly the best way since I
> am changing my network topology to unmount an offline filesystem. In
> some situations adding an IP to an interface is not possilble, and if
> the system is a remote system it could lead to more problems since it is
> mostly unresponsive.
>=20
> It would be greatly appreciated if a patch could be introduced that
> allows "umount -f" to actually work without making any other changes to
> a running system. The man page for umount even states that the -f
> argument can be used to unmount an unreachable nfs share -- but it
> almost never works.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Nathan,
 you don't say what kernel you are running....

 A change was made in Linux 3.12 (8033426e6bdb2690d302872ac1e1fadaec1a5581)
 which may address the problem you have.
 So if you are using a kernel older than that, try a newer kernel.
 This may not make "umount -f" work, but it should stop it from hanging.
 To make it work you might need to kill all the processes using the mount
 point first.

 Also, "umount -l" might be a suitable answer to your problems.

NeilBrown

--Sig_/Z9XLYwSFP15WBzk8k4Nt3kg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU74gcDnsnt1WYoG5AQI7bw//aGQ47g4bStBCW1OJmBuWhRzKTa7W9VBb
P7kUA3NSVdpWyCwyAoAdk18I4zrOEhNNPNm0apY4sLDyGVGlVOi9WCVhedQF3qs4
rZYY0dqfD2ErpCr6kmpJKUdNKWAtsNLSNUtV+KqDkZ++exVIiSwstD7yfKPKmhey
0bQP7tuWn2Do97pogAiZ7pr89RJKBi9Om6h5rmRf6V5mT+uXyyK5BMcX7Nf+VOyN
ay2OYtuBNT9TnFXYyKvwXz+kCrFTI0hx7QtDm+EIkOYw1v23v9DhqsKP5SS+e4+M
ceOUQLa88+orE1BHEAubchnfK2gUdaFoENPKsbwSebrVcMnZg+ZL4ieO74ikmpJo
ghLo6fAZ1tI8PhFr+wT1vlYLpafeCyd3uRQRfD7w6q0Az/gjl9qJEqPQs32t+YRl
uTACqg1oY4Q8C/ygxMmIjt70jeuRuehfNvbAWVP0R0WBf2qrIgpyW/L5KjTOtczL
iAKOKzla/64pw8nz6kea6e0sMBD8wwXjCEAE/uYnBExTYF96hpMSCVrvo2ZNCz5U
/RaZrOK+Qumub0/r8ODmEh6rTtgRN1Rye6hkcpnV3NIYpszxBHIW8P8RiBWO8LnJ
ls1c7hE6a1ZuH2HktzmusiTwr2FCvczsH+SV27wNsoZWdDTN6IEAdJ38sNiG5XNw
OzpMy12b/UA=
=Lc9Z
-----END PGP SIGNATURE-----

--Sig_/Z9XLYwSFP15WBzk8k4Nt3kg--
