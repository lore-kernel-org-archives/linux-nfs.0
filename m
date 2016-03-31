Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55688 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbcCaCom (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2016 22:44:42 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 83943AC32
	for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 02:44:40 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 31 Mar 2016 13:44:32 +1100
Subject: NFSv4.1 credential choice for the CLOSE operation
Message-ID: <87twjns6wf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


In NFSv4.1 the client can request, in the EXCHANGE_ID operation,
permission to use machine credentials to validate a CLOSE operation.
When the server gives that permission, it does *not* include implicit
permission to use the machine credentials for the PUTFH operation which
must precede CLOSE in the same request.

At least, I cannot see that RFC5661 gives that implicit permission and a
customer has a server that doesn't give that permission.

So I conclude that it is only safe to use the machine credentials if
NFS_SP4_MACH_CRED_CLEANUP is set *and* the security tuple for the
machine credential is a tuple which is permitted for the file handle.

So I came up with the following patch which I suspect is very wrong but
at least shows where I am looking.  And compiles :-)

Details of the problem situation is that even though kerberos is
configured and usable, the NFS client is mounting with sec=3Dsys and the
server is exporting with a similar setting.
So kerberos is used to provide a machine credential and to validate
state management, but AUTH_SYS is used for all file accesses.

In this context here is no *need* to use the machine credential to
validate CLOSE because AUTH_SYS credentials never expire.  But the linux
NFS client does anyway, and the server rejects the PUT_FH because it
wasn't authenticated with AUTH_SYS.

Can anyone suggest what a better fix would be - or explain to me how I
have misread the RFC?

Thanks a lot,
NeilBrown


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4afdee420d25..b1694890feb1 100644
=2D-- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -297,7 +297,9 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned lo=
ng sp4_mode,
 	struct rpc_cred *newcred =3D NULL;
 	rpc_authflavor_t flavor;
=20
=2D	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
+	if (test_bit(sp4_mode, &clp->cl_sp4_flags) &&
+	    (*clntp)->cl_auth->au_flavor
+	    =3D=3D clp->cl_rpcclient->cl_auth->au_flavor) {
 		spin_lock(&clp->cl_lock);
 		if (clp->cl_machine_cred !=3D NULL)
 			/* don't call get_rpccred on the machine cred -

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW/I8SAAoJEDnsnt1WYoG50LcP/R/nAySAwjyjPooSoYpfEmgF
VOP3zOMWWsz8i8nE2o+KjZ2i89ptvGwgvbKMnR/SNoswjOr6ZTbDC1yBU/T/Zw1p
f/Go1CrDAjkdkAbrQePiryMEcFyl/dFCi1GD1mHvxYYBC47rX0ZgYuz2+pnBpSyi
pOJQWyqbeos3QFfOfVX0Qmo0h/ySRPfWZptB59sgDONJB+yoXsLsqYjveGhXHb7s
jWn5vakXiKHwrWATUapYOL+hpKheToWSKRQeUqorNtUY5p2V8ptjK5Kmk3SUTDLr
E3iZs/+m6OBm8NbvXcKqdPUqmimMW7Qydb3pUWV48t/25FSlPQ/QD8xtVioDQZi/
EriOEzUbQNoo93mA/BAszkDMikirLWw2Dha6zmQDXj/ywzhlENkDTuEQl2Wf4vgC
Pe+RKHRijX38+BpJBfxEYpihZCLwr4+FWkMv5I4b3DUMyHfi8ujjA5xAI6CkUY8K
5W4nCvSNCEYzyC+tei8TvcOrZdhn0B2hHSAhtXUtLQ4B3TuuoXajkexFuPf3qHD2
xXc4a1jI9cfEi2+xSYUAQ6N9Lt/CZa5fj5im5K4rBLWRFip4EaCNHa2BPEbJ1w4b
whG6CFKpAZ4jdQOPt496NQH+J5E+1zkVjXzXGV5WtZa4ictpp42xnaUix3v0VkYr
GGCcn3Cv5tpy2QGFptHp
=7ggs
-----END PGP SIGNATURE-----
--=-=-=--
