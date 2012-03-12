Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:32958 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950Ab2CLVSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 17:18:23 -0400
Received: from pip.fifthhorseman.net (dsl254-070-154.nyc1.dsl.speakeasy.net [216.254.70.154])
	by che.mayfirst.org (Postfix) with ESMTPSA id 27BE0F970
	for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 17:18:21 -0400 (EDT)
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: linux-nfs@vger.kernel.org
Subject: rate-limiting state manager error messages?
Date: Mon, 12 Mar 2012 17:18:14 -0400
Message-ID: <87ty1t4iy1.fsf@pip.fifthhorseman.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Hi folks--

with kernel 3.2.0, if something goes wrong with the NFSv4 handshake, i'm
seeing over a thousand messages a second like this:

Mar  5 12:10:21 coconut kernel: [18246.427246] Error: state manager failed on NFSv4 server molly with error 13
Mar  5 12:10:21 coconut kernel: [18246.428329] Error: state manager failed on NFSv4 server molly with error 13
Mar  5 12:10:21 coconut kernel: [18246.429370] Error: state manager failed on NFSv4 server molly with error 13
Mar  5 12:10:21 coconut kernel: [18246.430263] Error: state manager failed on NFSv4 server molly with error 13
Mar  5 12:10:21 coconut kernel: [18246.430990] Error: state manager failed on NFSv4 server molly with error 13


This can very rapidly fill the logs on a client with a small /var
filesystem, without providing much in the way of useful feedback to the
administrator.

Could these printk's be rate-limited ?

      --dkg

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQJ8BAEBCgBmBQJPXmgYXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznpjvoP/jrOFOWiQDebH9P50sh2HUAE
rFvJ/4QOcyYfx0jjZzdCQZvJ+PGFnTX6mk24FBgdT/7M6248ZoWk+MK2ExF/KUs/
yXuiau1LAixY5AoGoImEC7+FBbzYpK7s4GtnhkqAdMuz/SRdVgpe6AUtwPdn1ln6
tX9WAcHeeZ0uCLAV2b4ZS/lpoOAYplu5qTBD6P0bFx8b4FYm85MzivQCiT7Sop6A
xusOs0ROXAL2ZXMtyUql3wdudGk0/UtOqpw6uNtWTsN7rWEjFzBtg9aXXfaftnrN
NzY7ybqTL9JxbdEar1Rk5oZvepywrgTnoIYx0+V26Wn0GQo+h1VIKqcenMt8bP/2
e6W9sGeN+c3b1Vy+52dBp8TwRae3UeY3Gh+GBJwDGF5unQuzgKG/REZggvXHjmPW
LhjrjN6TMo7FaorVTvzHqlY5BYMeYiubt5mR3HOPt8ealPrhV1NuFzqSEGoOnGY0
k5W1oUAJbzyN1KVPhg5nnu/UIp3mEy+H94JcryuG1ZPqygQGnUdYXUv6bVJEb0cn
1WZwbnUJuhgLODqWZTHft1yX3c2Kj2aqAaZ8cKQIjnV2Ux+uwPqEhg4nErlKHbQe
kRJzCw6uYuO09VjJ7b0J87G1afH1DKtOnogwFu+9PzNHWLlGl/6w8idpE+s/Twhv
ZbNQOkrETuKbUfin9y+E
=nABz
-----END PGP SIGNATURE-----
--=-=-=--
