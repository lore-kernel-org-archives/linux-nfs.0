Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:40250 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab3FFNan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jun 2013 09:30:43 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UkaB8-0003XY-Ju
	for linux-nfs@vger.kernel.org; Thu, 06 Jun 2013 15:24:35 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1UkaB4-0004ZD-R0
	for linux-nfs@vger.kernel.org; Thu, 06 Jun 2013 15:24:30 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: NFS4+KRB5 trouble in Kernel >3.8
Date: Thu, 6 Jun 2013 13:24:30 +0000 (UTC)
Message-ID: <koq2ie$gtu$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

seems I have been bitten again by the same Problem as back in November
(http://comments.gmane.org/gmane.linux.nfs/52916).

Well, at least the symptoms are the same. The problem is almost
certainly another one.

In recent kernels (e.g. 3.9.4) again my mount seems to hang infinitely:

mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/tmp 

This time I immediately tried to bisect this, but what happens is that half
the way down bisecting the symptoms change. The mount does not hang anymore,
but I get "access denied" now:

 ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/tmp
mount.nfs4: access denied by server while mounting testsrv:/storage

So how to continue bisecting? Should I mark this as good or bad?

Here is the output of "git bisect log" so far:

git bisect start
# good: [dbf932a9b316d5b29b3e220e5a30e7a165ad2992] Linux 3.8.13
git bisect good dbf932a9b316d5b29b3e220e5a30e7a165ad2992
# bad: [0bfd8ffeff9dda08c69381d65c72e0aa58706ef6] Linux 3.9.4
git bisect bad 0bfd8ffeff9dda08c69381d65c72e0aa58706ef6
# good: [19f949f52599ba7c3f67a5897ac6be14bfcb1200] Linux 3.8
git bisect good 19f949f52599ba7c3f67a5897ac6be14bfcb1200
# good: [ef53d16cded7f89b3843b7a96970dab897843ea5] ksm: allocate roots when needed
git bisect good ef53d16cded7f89b3843b7a96970dab897843ea5

I did not mark the current state with either good or bad yet.

Regards

Sven

-- 
Software patents are the software project equivalent of land mines: Each
design decision carries a risk of stepping on a patent, which can destroy
your project. (Richard M. Stallman)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
