Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:33739 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab2BMKvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Feb 2012 05:51:53 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1RwtVe-0005ck-OF
	for linux-nfs@vger.kernel.org; Mon, 13 Feb 2012 11:51:50 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1RwtVc-0006q5-DD
	for linux-nfs@vger.kernel.org; Mon, 13 Feb 2012 11:51:48 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: mount hangs in NFS4+Kerberos setup
Date: Mon, 13 Feb 2012 10:51:48 +0000 (UTC)
Message-ID: <jhaq04$pev$1@ultimate100.geggus.net>
References: <20120210154526.7b504146@little-poseidon> <4F35512A.9050500@steve-ss.com> <20120210184154.03fb6907@little-poseidon>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

whats_up@gmx.net wrote:

> What's your suggestion to improve/secure my configuration?

I already told you that you need a backport of the latest version of
libtirpc. The Version included in squeeze is broken.

Sven

-- 
If you can spend five minutes on the Internet and do not run Linux,
you're a genius. (Dirk Hohndel)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
