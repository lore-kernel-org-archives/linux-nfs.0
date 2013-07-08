Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:48322 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3GHPyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 11:54:09 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UwDlP-0003Ho-L7
	for linux-nfs@vger.kernel.org; Mon, 08 Jul 2013 17:54:08 +0200
Date: Mon, 8 Jul 2013 17:54:06 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130708155406.GA7808@geggus.net>
References: <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
 <20130702080530.GA17953@geggus.net>
 <20130705181859.GA8288@fieldses.org>
 <20130705203435.GE8288@fieldses.org>
 <20130708080803.GB29990@geggus.net>
 <20130708133537.GA29071@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130708133537.GA29071@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Montag, den 08. Juli um 15:35 Uhr:

> Anyway.  OK, that more or less solves the mystery, though the strace
> output might still be interesting.

Not very enlightening, at least for me, but here we go:

read(3, "nfsd 10.1.7.30\n", 2048)       = 15
close(13)                               = 0
open("/var/lib/nfs/etab", O_RDONLY)     = 13
close(13)                               = 0
close(13)                               = 0
write(3, "nfsd 10.1.7.30 1373300439 * \n", 29) = 29
read(4, "4294967295\n", 2048)           = 11
close(14)                               = 0
close(13)                               = 0
read(13, "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0", 36) = 36
close(13)                               = 0
write(4, "4294967295 1373300439 0 \n", 25) = -1 EINVAL (Invalid argument)

Regards

Sven

-- 
The source code is not comprehensible
                 (found in bug section of man 8 telnetd on Redhat Linux)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
