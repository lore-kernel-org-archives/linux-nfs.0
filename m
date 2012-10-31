Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:59474 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422908Ab2JaPde (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Oct 2012 11:33:34 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TTaIP-0003UI-2t
	for linux-nfs@vger.kernel.org; Wed, 31 Oct 2012 16:33:33 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1TTaIO-0004yz-Ev
	for linux-nfs@vger.kernel.org; Wed, 31 Oct 2012 16:33:32 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Date: Wed, 31 Oct 2012 15:33:32 +0000 (UTC)
Message-ID: <k6rgcc$igt$1@ultimate100.geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net> <20121026171549.GA11806@fieldses.org> <20121029094038.GA14836@geggus.net> <20121029150203.GB9502@fieldses.org> <20121029163323.GA24345@geggus.net> <k6r6ur$eva$2@ultimate100.geggus.net> <CAA7C2qiiHzwMmkm5fUyNCffejxACtsDu0Pb1qgYJPCfgcaZU-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

VDR User <user.vdr@gmail.com> wrote:

> In case you missed my previous message, "I use debian testing here and
> NFSv4. My clients are running kernel 3.6.3, server is running 3.6.2.  No
> problems here".

No, I did not miss your post. I even asked if you are using sec=krb5. I did
not try if it works without using kerberos, because I am not interested in
"No File Security" NFS3-like mode.

> It would seem you only need to cherry-pick server changes between 3.6.2
> and 3.6.3...?

Unfortunately not. It already did not work using 3.6.2

Regards

Sven

-- 
"Der wichtigste Aspekt, den Sie vor der Entscheidung für ein Open
Source-Betriebssystem bedenken sollten, ist, dass Sie kein
Windows-Betriebssystem erhalten." (von http://www.dell.de/ubuntu)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
