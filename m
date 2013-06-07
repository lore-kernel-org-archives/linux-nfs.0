Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:43025 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047Ab3FGKUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Jun 2013 06:20:00 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Uktm3-0005MI-Lp
	for linux-nfs@vger.kernel.org; Fri, 07 Jun 2013 12:19:59 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Uktm0-0002Y4-Ce
	for linux-nfs@vger.kernel.org; Fri, 07 Jun 2013 12:19:56 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4+KRB5 trouble in Kernel >3.8
Date: Fri, 7 Jun 2013 10:19:56 +0000 (UTC)
Message-ID: <kosc4c$9ar$1@ultimate100.geggus.net>
References: <koq2ie$gtu$1@ultimate100.geggus.net> <DBA14DEF-59CE-4068-B2B8-7F208F2EBA22@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> wrote:

> Perhaps you could try enabling debugging first to see where the hang occurs.
> 
>  $ sudo rpcdebug -m nfs -s all
> 
> then add "-vvv" on the rpc.gssd command line.  Try your mount again, and look in /var/log/messages.

Client or server side or both?

As you have been talking about rpc.gssd I assume client side, right?

Sven

-- 
Software patents are the software project equivalent of land mines: Each
design decision carries a risk of stepping on a patent, which can destroy
your project. (Richard M. Stallman)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
