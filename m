Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:34442 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755136Ab2HUJTG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 05:19:06 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T3kc4-0006xO-GA
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 11:19:04 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T3kc3-0006Si-Rf
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 11:19:03 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: NFS4ERR_DELAY (was: NFS4: ssh + unlink(~/.Xauthority) delays)
Date: Tue, 21 Aug 2012 09:19:03 +0000 (UTC)
Message-ID: <k0vjq7$o7l$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> So the question is what cases hangs in NFS4 based Linux systems in general
> an in this particular case?

Digging this down a little bit further using wireshark I figured out that
the server responds to the REMOVE .Xauthority call with an NFS4ERR_DELAY for
whatever reason.

This is a currently a test-machine with one single user and next to zero
load.

So I will probably need a hint on how to debug the server behaviour, as a
NFS4ERR_DELAY response is definitely not expected in this case.

Sven

-- 
"Das Einzige wovor wir Angst haben müssen ist die Angst selbst"
						(Franklin D. Roosevelt)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
