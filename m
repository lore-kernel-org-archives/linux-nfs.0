Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:32880 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342Ab3F0Hlt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jun 2013 03:41:49 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Us6pw-0005c5-Go
	for linux-nfs@vger.kernel.org; Thu, 27 Jun 2013 09:41:48 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Us6pv-0007j1-Mb
	for linux-nfs@vger.kernel.org; Thu, 27 Jun 2013 09:41:47 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
Date: Thu, 27 Jun 2013 07:41:47 +0000 (UTC)
Message-ID: <kqgqbr$sv2$1@ultimate100.geggus.net>
References: <51BF21E0.8060805@gmail.com> <51BF23FE.4070106@gmail.com> <3E91EC3C-EA92-41A6-9EDA-42E108E83024@oracle.com> <51BFBA5A.5050104@gmail.com> <8565C805-9C6C-4C06-83C0-8574EA90DA53@oracle.com> <51C0AB95.9060509@gmail.com> <EB30924A-D9F1-49C5-A727-DF8B4B2AFDAC@oracle.com> <CAFYD6QXKcNkAgmJV5KyMOpx-cXg35GnYzBg9mg+LFdW83NyQZQ@mail.gmail.com> <A2112E2B-FA65-4FF2-BC21-B78BBDC75CB1@oracle.com> <51CBDC5F.8090109@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

John Haiducek <jhaiduce@gmail.com> wrote:

> I upgraded my system to Debian experimental yesterday and that fixed my 
> NFS problem.

NFS userland is newer in testing/unstable 1.2.8 vs. 1.2.6 so did you
downgrade those as well?

Sven

-- 
"Das ist halt der Unterschied: Unix ist ein Betriebssystem mit Tradition,
 die anderen sind einfach von sich aus unlogisch."
                          (Anselm Lingnau in de.comp.os.unix.discussion)
/me ist giggls@ircnet, http://sven.gegg.us/ im WWW
