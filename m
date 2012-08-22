Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:55286 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab2HVIdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Aug 2012 04:33:06 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T46N6-0003As-0L
	for linux-nfs@vger.kernel.org; Wed, 22 Aug 2012 10:33:04 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T46N5-0005dl-BL
	for linux-nfs@vger.kernel.org; Wed, 22 Aug 2012 10:33:03 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4ERR_DELAY
Date: Wed, 22 Aug 2012 08:33:03 +0000 (UTC)
Message-ID: <k125fv$kvl$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net> <k0vjq7$o7l$1@ultimate100.geggus.net> <20120821064100.701ec6e9@corrin.poochiereds.net> <k100a0$sm1$1@ultimate100.geggus.net> <20120821090706.3833fdf6@corrin.poochiereds.net> <20120821174740.GC15958@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> Yep.  There's a recent regression which could cause this; could you try:
> 
>        https://lkml.org/lkml/2012/8/16/531

Patch applied, problem solved.

Thanks

Sven

-- 
Um Kontrolle Ihres Kontos wiederzugewinnen, klicken Sie bitte auf das
Verbindungsgebrüll. (aus einer Ebay fishing Mail)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
