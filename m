Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:41835 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971Ab1CVX1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 19:27:31 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Q2Az3-0001RI-9j
	for linux-nfs@vger.kernel.org; Wed, 23 Mar 2011 00:27:29 +0100
Received: from d67-193-214-242.home3.cgocable.net ([67.193.214.242])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 00:27:29 +0100
Received: from brian by d67-193-214-242.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 00:27:29 +0100
To: linux-nfs@vger.kernel.org
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: different kernels mean NFS4/GSSAPI works or doesn't
Date: Tue, 22 Mar 2011 19:27:17 -0400
Message-ID: <imbb8m$uiv$1@dough.gmane.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2C35B50DE41248F6F8C7F77B"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig2C35B50DE41248F6F8C7F77B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I was hoping I could bring a kernel.org ticket that I filed to your
attention in the hopes that somebody might have an epiphany.

https://bugzilla.kernel.org/show_bug.cgi?id=3D31442

This is a strange problem where simply booting to a different kernel,
even within the same release stream (2.6.32) can result in an NFS server
that doesn't seem to want to respond to GSSAPI mount requests.

I was working with Trond on it and it got as far as my reporting what
rpc.gssd is doing when a failed (blocked in fact) mount request happens:

pc# rpc.gssd with the -f -vvv
beginning poll
handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt6e1)
handle_gssd_upcall: 'mech=3Dkrb5 uid=3D0 enctypes=3D18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt6e1)
process_krb5_upcall: service is '<null>'
Full hostname for 'linux.example.com' is 'linux.example.com'
Full hostname for 'pc' is 'pc'
Key table entry not found while getting keytab entry for 'root/pc@ILINX'
Key table entry not found while getting keytab entry for 'nfs/pc@ILINX'
Key table entry not found while getting keytab entry for 'host/pc@ILINX'
Success getting keytab entry for nfs/*@ILINX
WARNING: Key table entry not found while getting initial ticket for
principal
'nfs/pc.example.com@ILINX' using keytab 'WRFILE:/etc/krb5.keytab'
ERROR: No credentials found for connection to server linux.example.com
doing error downcall
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e1
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e0
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6df
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e4
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt6e3

pc$ sudo mount -t nfs4 -o sec=3Dkrb5 linux:/tmp /mnt/tmp
mount.nfs4: access denied by server while mounting linux:/tmp

Now granted, this isn't a block/hang on the mount, but this was also
after having removed 3des entries from my keytabs.  I wasn't getting
access denied before removing the 3des keytab entries but was getting
blocked mount.nfs4 commands on the client.

More gory details are in the ticket.

Any next debugging steps?

Cheers,
b.


--------------enig2C35B50DE41248F6F8C7F77B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2JMFUACgkQl3EQlGLyuXBQRwCg2Z4xPu0Z9gcRd0USVLokgut3
cxkAoJQRCNCoXfEdJPcjJIT4ozR489DS
=Iz75
-----END PGP SIGNATURE-----

--------------enig2C35B50DE41248F6F8C7F77B--
