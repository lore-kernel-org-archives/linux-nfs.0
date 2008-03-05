From: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Subject: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 05 Mar 2008 12:52:57 -0800
Message-ID: <47CF0829.4020502@m2000.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA6E01B229B763E4BA9F022EB"
Cc: Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>, jesper.juhl@gmail.com,
	Trond.Myklebust@netapp.com, Neil Brown <neilb@suse.de>
To: lkml@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from asterix.m2000.com ([212.155.102.83]:3069 "EHLO
	asterix.m2000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761688AbYCEVVU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2008 16:21:20 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA6E01B229B763E4BA9F022EB
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

     Running SLES 10 on multiple compute nodes, with an OpenSuSE 10.2 NFS=

server, and I am receiving the above log message on a semi-regular basis
in the NFS client system-logs. When this occurs, one of the users
receives an error (although there seems to be no way to easily collate
the users experience with the system log, short of using the timestamp).
     Sometimes it's "read/write error", sometimes it's more specific
about something that was a file now being a directory (SVN tends to be
rather more verbose). Most of the time this is just a nuisance, but at=20
times (such as last week or so) it occurs so often that it blocks any=20
work getting done.

     The NFS Server is running OpenSuSE 10.2 on a Dell PowerEdge 2900=20
with the PERC5/i controller. The NFS Clients are all SLES10 with the=20
standard mountoptions, and running in TCP mode (something about UDP +=20
NFS + GbE leads to subtle data corruption).

     I have been able to find some references to this problem in Google,
but no solutions, and no discussion about what the problem stems from,
nor if any fixes have been attempted.




--------------enigA6E01B229B763E4BA9F022EB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHzwgryWYDdvnGArwRAvhVAJ905vC0SQemjCo7cnS+bcml6SizJgCgi5A4
rwGZQ1gusQFrJDU8ggOkZUA=
=fbD6
-----END PGP SIGNATURE-----

--------------enigA6E01B229B763E4BA9F022EB--
