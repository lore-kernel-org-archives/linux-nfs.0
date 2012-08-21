Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:34250 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757733Ab2HUQEa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 12:04:30 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T3qwP-0001BO-3V
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 18:04:29 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T3qwN-0000Rz-4B
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 18:04:27 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Date: Tue, 21 Aug 2012 16:04:27 +0000 (UTC)
Message-ID: <k10bib$1fi$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net> <20120821125905.GA16550@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees <rees@umich.edu> wrote:

> No, the question is why did X put that file in your home directory.  That's
> not where it belongs.  I've got this in my .xinitrc:
> 
> setenv XAUTHORITY /tmp/Xauthority`id -u`

I agree, that ~/.Xauthority is probably not the best place for this file,
but it is the default (at least in Debian).

If it is expected behaviour that this will not work correctly with shared
Homedirectories, I wonder why this did not cause me any trouble with NFS3
for many years.

Anyway I did not yet figure out how to globally change the XAUTHORITY
Variable in kdm and ssh :(

Sven

-- 
Microsoft ist offenbar die einzige Firma, die in der Lage ist, ein mit
Office nicht kompatibles Bürosoftwarepaket einzuführen.
                            (Florian Weimer in de.alt.sysadmin.recovery)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
