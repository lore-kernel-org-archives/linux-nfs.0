Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:39792 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423539Ab3FUU7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 16:59:50 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Uq8Qu-0002cU-VT
	for linux-nfs@vger.kernel.org; Fri, 21 Jun 2013 22:59:49 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Uq8Qu-0006VB-CV
	for linux-nfs@vger.kernel.org; Fri, 21 Jun 2013 22:59:48 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4 + KERB + AD 2008 Troubles
Date: Fri, 21 Jun 2013 20:59:48 +0000 (UTC)
Message-ID: <kq2es4$o1t$2@ultimate100.geggus.net>
References: <2182E21644AEEF4BAC775CC0609AE30C1E2AF5D1@GLORFINDEL.noveltis.loc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thierry Lamoureux <thierry.lamoureux@noveltis.fr> wrote:

> - One linux NFS Server under Debian Squeeze, named nfsserver
> - One linux NFS Client under Debian Squeeze, named nfsclient

Oh, I just read about Debian Squeeze right now. If I remember
correctly, there is at least one NFS4 related library in squeeze
which is broken.

If you want to use NFS4 I would strongly suggest to upgrade to
wheezy!

However note, that some Versions of the vanilla kernel (as server)
might be broken.

I have some trouble using 3.9.x riht now. 3.8.x works fine, as should
the 3.2.x distribution kernel fron wheezy.

Sven

P.S.: I'm succesfully running all this stuff on my workplace for
quite some time now.

-- 
Das Internet wird vor allem von Leuten genutzt, die sich Pornografie
ansehen, während sie Bier trinken, es ist daher für Wahlen nicht
geeignet (Jaroslaw Kaczynski)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
