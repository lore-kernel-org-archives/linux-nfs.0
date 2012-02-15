Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:60292 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647Ab2BOJ5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 04:57:15 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Rxbbt-0007dy-Nl
	for linux-nfs@vger.kernel.org; Wed, 15 Feb 2012 10:57:13 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Rxbbt-00051r-4L
	for linux-nfs@vger.kernel.org; Wed, 15 Feb 2012 10:57:13 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: mount hangs in NFS4+Kerberos setup
Date: Wed, 15 Feb 2012 09:57:13 +0000 (UTC)
Message-ID: <jhfvhp$hu6$2@ultimate100.geggus.net>
References: <20120210154526.7b504146@little-poseidon> <4F35512A.9050500@steve-ss.com> <20120210184154.03fb6907@little-poseidon> <jhaq04$pev$1@ultimate100.geggus.net> <20120213195053.0db35dd9@little-poseidon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

whats_up@gmx.net wrote:

> - install version 0.2.2 of libtirpc from unstable (forced new libc6)

Don't do this. Just backport yourself. This is trivial in that case (apt-get
source + dpkg-buildpackage)

Sven

-- 
Das Internet ist kein rechtsfreier Raum, das Internet ist aber auch
kein bürgerrechtsfreier Raum. (Wolfgang Wieland Bündnis 90/Die Grünen)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
