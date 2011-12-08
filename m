Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:44965 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab1LHPiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 10:38:00 -0500
Received: from pip.fifthhorseman.net (lair.fifthhorseman.net [108.58.6.98])
	by che.mayfirst.org (Postfix) with ESMTPSA id 047A3F970
	for <linux-nfs@vger.kernel.org>; Thu,  8 Dec 2011 10:29:30 -0500 (EST)
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: linux-nfs@vger.kernel.org
Subject: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out Please check user daemon is running
Date: Thu, 08 Dec 2011 10:29:42 -0500
Message-ID: <8762hrozdl.fsf@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Hello Linux-NFS folks--

I've got an nfs4 server running linux kernel 3.1.1 with nfs-utils 1.2.4.

When an NFSv4 client connects to the server using sec=krb5p, the kernel
emits:

[ 3505.754807] RPC: AUTH_GSS upcall timed out.
[ 3505.754810] Please check user daemon is running.

It's true, i don't have rpc.gssd running on the server (though i do have
rpc.svcgssd running).

But the client can go ahead and mount the filesystem anyway, and users
with the appropriate krb5 credentials on the clients can access files on
the server based on their credentials.

So it's not clear to me what this warning is about.   Should i be
running rpc.gssd on the nfs server?  If so, what functionality am i
losing out on by not running it?  If i don't need to run it, why is the
kernel emitting this message?

       --dkg

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQJ8BAEBCgBmBQJO4NfmXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznp73gQAJhX95dCnLl71SbTt0SFgtSp
Zt5VIV54Ee62aA1NswtD771QTs3oiVjsop/us2A4Ux+jUjR8HycbJ9mFcgsW4oxE
+DuMPtGD5JmGSlXX06PoJBtbPSrqdBbRqyjAwjEfIONkkhmMtqPDhkyCrRDdeGDY
2rhKybhAFbza7yl851UOtbY3PlLXc+G3dXs8jHi6Mbtts76Nr9okDZ+vuIrMXfN+
tzAEwOxsao+loLkD2H1EWJDCoolKe72tf/VAeupQIzn7hOy7dMtIxYk8fKkp2oV+
viy/kFZYV0l+1En4VHPeImRS6i9yUkZzZDznvRE7By2byghSKSgd96ftXttzSbIr
Q1lx1rpYv+Q8ocguar3lCbS+9BR7AkxQ7T8pVW1XtDv/IsOW7v8pB8p8V/OL5HY1
sxJtIAQBENwBzvqP0a0R/4ms9nRmtjrk6ey3fiCLGMUUCKCYdxOFRIjHG/NF3fXd
NVo42+/dltpcepwLJERGGjcR2B+PLCDgCiND7uue5HLOkcAl2okyAToG0vjTDmjg
qDdioADlPrQ+S8ctOUbBXX2Gs9MxRXfV397JsY4bN9BQsixXgXMr4P04E89z0NRA
H62RfRR+++m2qhsHg7WC0RXD+t2Kz9Dob+nrlLs7/dzmz4aEhy0eqi5pi6b1NP/8
BOdklJLDNYawZGIS2sIG
=5Z46
-----END PGP SIGNATURE-----
--=-=-=--
