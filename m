Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:37445 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab2KLJRU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 04:17:20 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TXq8s-0006ea-R9
	for linux-nfs@vger.kernel.org; Mon, 12 Nov 2012 10:17:18 +0100
Date: Mon, 12 Nov 2012 10:17:17 +0100
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121112091717.GA1610@geggus.net>
References: <20121109200730.GI6171@fieldses.org>
 <E1TWxKX-00025I-J2@diesel.geggus.net>
 <20121109232410.GK6171@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20121109232410.GK6171@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Samstag, den 10. November um 00:24 Uhr:

OK, back at work and here is what I get:

> Restart the server, start strace, then try the mount, let it hang a few
> seconds just to make sure you got anything interesting, then kill strace
> and send the output.

OK, back at work and here is what I get...

read(3, "nfsd 10.1.7.30\n", 2048)       = 15
close(15)                               = 0
open("/var/lib/nfs/etab", O_RDONLY)     = 15
close(15)                               = 0
close(15)                               = 0
write(3, "nfsd 10.1.7.30 1352710828 * \n", 29) = 29
read(4, "4294967295\n", 2048)           = 11
close(16)                               = 0
close(15)                               = 0
read(15,
"\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0",
36) = 36
close(15)                               = 0
write(4, "4294967295 1352710828 0 \n", 25) = -1 EINVAL (Invalid argument)

4294967295 is UINT_MAX and this place is where it behaves differently on a good
kernel where the write call will succeed:

write(4, "4294967295 1352710828 0 \n", 25) = 25

Sven

P.S.: Your patched svcauth_gss.c will give me an "access denied by server"
while mounting instead of the infinite delay:
 ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/
mount.nfs4: access denied by server while mounting testsrv:/storage

-- 
Those who would give up Essential Liberty to purchase a little Temporary
Safety, deserve neither Liberty nor Safety (Benjamin Franklin)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
