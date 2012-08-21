Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:42735 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab2HUMwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 08:52:20 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T3nwQ-0005AV-PF
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 14:52:18 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T3nwO-0007go-OC
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 14:52:16 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4ERR_DELAY
Date: Tue, 21 Aug 2012 12:52:16 +0000 (UTC)
Message-ID: <k100a0$sm1$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net> <k0vjq7$o7l$1@ultimate100.geggus.net> <20120821064100.701ec6e9@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> It's often the case that this indicates a problem communicating over
> the callback channel. For instance, the server is trying to recall a
> delegation but the client isn't responding, so the server has to wait
> until the recall attempt times out before proceeding.

Hm I'm not shure if I understand this correctly.

I am talking about exactly 3 machines (and one single user for now) here:
clientA, clientB and the NFS-server.

"user" is logged in on clientA any now opens a shell to ssh to clientB.

The NFS-server is providing the home for the user on both machines.

The ssh is now getting delayed for up to 1 minute because the NFS server
does not allow for the .Xauthority file to be deleted immediately.

It is probably worth to mention, that I'm currently experimenting with
btrfs on the server. Is there a chance that this bug will disapper when I
change the underlaying filesystem of the server to ext4?

Sven

-- 
Trotz der zunehmenden Verbreitung von Linux erfreut sich der Bär,
und - dank Knut - insbesondere der Eisbär, deutlich größerer
Beliebtheit als der Pinguin. (Gefunden bei http://telepolis.de/)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
