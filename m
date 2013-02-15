Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:51295 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932943Ab3BOJiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 04:38:00 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1U6Hjz-0004Wa-6g
	for linux-nfs@vger.kernel.org; Fri, 15 Feb 2013 10:37:59 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1U6Hjx-0002wp-31
	for linux-nfs@vger.kernel.org; Fri, 15 Feb 2013 10:37:57 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: NFS4: "Value too large for defined data type" problem
Date: Fri, 15 Feb 2013 09:37:57 +0000 (UTC)
Message-ID: <kfkvll$adm$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

is there something which can be done server-side to work around the "Value
too large for defined data type" problem with huge inode Numbers?

First of all, I'm not shure if this is an NFS problem or one of the
underlying filesystem.

Background:
I set up a new NFS-server (NFS4) recently. The server works fine so far with
64 bit Linux clients.

It also mostly works with 32 bit Linux clients when either the stat system
call is not used or "-D_FILE_OFFSET_BITS=64" has been used.

This is because on 32 bit Linux ino_t is not 64-bit otherwise.

Unfortunately at least the 32bit Version of Debian stable (6.0) seems to
break all over the place. E.g. in gnome when stat ~/.gnome2_private/ fails
it is assumed that the directory has to be created which will of course make
the subsequent call to mkdir also fail and break the whole desktop
environment afterwords.

Regards

Sven

-- 
Um Kontrolle Ihres Kontos wiederzugewinnen, klicken Sie bitte auf das
Verbindungsgebrüll. (aus einer Ebay fishing Mail)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
