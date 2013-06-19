Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:54692 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756623Ab3FSNrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jun 2013 09:47:22 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UpIjJ-0007WI-H8
	for linux-nfs@vger.kernel.org; Wed, 19 Jun 2013 15:47:21 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1UpIjI-0004CG-LA
	for linux-nfs@vger.kernel.org; Wed, 19 Jun 2013 15:47:20 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Date: Wed, 19 Jun 2013 13:47:20 +0000 (UTC)
Message-ID: <kpscp8$fo3$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I just tried using Kernel 3.10.0-rc2 an my NFS-server test VM and I'm still
unable to run a working kerberized NFS-Server with this kernel.

To make it work I would have to go back to Kernel 3.8.x (which i can't
because I want to use drbd 8.4).

Any hints on how to furter debug this?

As I already said, I failed in "git bisecting" the Problem because the
behaviour changed from broken behaviour (infinite hang) to another broken
behaviour (permission denied) while doing so.

Sven


-- 
"We don't know the OS that God uses, but the Vatican uses Linux"
                               (Sister Judith Zoebelein, Vatican Webmaster)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
