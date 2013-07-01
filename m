Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:49205 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738Ab3GAMJW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 08:09:22 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Utcv3-0000LS-CM
	for linux-nfs@vger.kernel.org; Mon, 01 Jul 2013 14:09:21 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Utcv1-00070Y-Qr
	for linux-nfs@vger.kernel.org; Mon, 01 Jul 2013 14:09:19 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Date: Mon, 1 Jul 2013 12:09:19 +0000 (UTC)
Message-ID: <kqrrhf$q98$1@ultimate100.geggus.net>
References: <kpscp8$fo3$1@ultimate100.geggus.net> <20130619213412.GA2547@fieldses.org> <20130620080354.GA5591@geggus.net> <20130620144955.GB11728@fieldses.org> <20130620145209.GC11728@fieldses.org> <20130621083221.GA4103@geggus.net> <20130624215408.GD23596@fieldses.org> <20130625094612.GA2186@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just an update on this. I tried to compile Linux 3.10 now and updated
my userland to nfs-utils 1.2.8 (from Debian unstable).

The Problem persists. NFS-Server stops working ith any vaniall Kernel newer
than 3.8.x including 3.10.

Sven

-- 
Um Kontrolle Ihres Kontos wiederzugewinnen, klicken Sie bitte auf das
Verbindungsgebrüll. (aus einer Ebay fishing Mail)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
