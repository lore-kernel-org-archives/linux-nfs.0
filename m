Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:55085 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab3FZMqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 08:46:21 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Urp75-0005pw-Il
	for linux-nfs@vger.kernel.org; Wed, 26 Jun 2013 14:46:19 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Urp74-0001Hz-V4
	for linux-nfs@vger.kernel.org; Wed, 26 Jun 2013 14:46:18 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: exporting one directory sec=krb5 and another sec=sys?
Date: Wed, 26 Jun 2013 12:46:18 +0000 (UTC)
Message-ID: <kqenqq$4f7$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm trying to do the following in /etc/exports:

/storage/home *(rw,sec=krb5:krb5i:krb5p,no_subtree_check)
/storage/data4hostx hostx(rw,sec=sys,no_subtree_check)

This does however not seem to work, I always seem to get "mount.nfs4:
Operation not permitted".

If I remove either line everything works fine
(of course in the spezified case only)

What am I doing wrong here?

Sven

-- 
Those who would give up Essential Liberty to purchase a little Temporary
Safety, deserve neither Liberty nor Safety (Benjamin Franklin)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
