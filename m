Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:38490 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423415Ab3FUUvj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 16:51:39 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Uq8J0-00025w-Hi
	for linux-nfs@vger.kernel.org; Fri, 21 Jun 2013 22:51:38 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Uq8Iy-0006SK-PD
	for linux-nfs@vger.kernel.org; Fri, 21 Jun 2013 22:51:36 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4 + KERB + AD 2008 Troubles
Date: Fri, 21 Jun 2013 20:51:36 +0000 (UTC)
Message-ID: <kq2eco$o1t$1@ultimate100.geggus.net>
References: <2182E21644AEEF4BAC775CC0609AE30C1E2AF5D1@GLORFINDEL.noveltis.loc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thierry Lamoureux <thierry.lamoureux@noveltis.fr> wrote:

> Package installation
> - nfs-common
> - winbind

What I actually miss in your list ist some kind of nss module.

Bevore thinking about getting NFS4 to work at all you have to be able
to "resolv" you users on both, nfs client _and_ server via nfs.

I would sugest libnss-ldapd or sssd rather than windbind.
libnss-winbind might work as well, but I+m not using this.

Anyway, does "getent passwd <some-userid>" work fine on you client
and server?

Regards

Sven

-- 
                       This APT has Super Cow Powers.
					(apt-get --help on debian woody)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
