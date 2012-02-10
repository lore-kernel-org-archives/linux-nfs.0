Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:60972 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742Ab2BJOwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 09:52:10 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1RvrpX-0000Oo-PW
	for linux-nfs@vger.kernel.org; Fri, 10 Feb 2012 15:52:07 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1RvrpX-0002fp-86
	for linux-nfs@vger.kernel.org; Fri, 10 Feb 2012 15:52:07 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: mount hangs in NFS4+Kerberos setup
Date: Fri, 10 Feb 2012 14:52:07 +0000 (UTC)
Message-ID: <jh3aun$9sj$1@ultimate100.geggus.net>
References: <20120210154526.7b504146@little-poseidon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

whats_up@gmx.net wrote:

> Any hints to fix the issue or to get more helpful debug information are
> welcome.

I would at least recomend using a recent kernel and backports of nfs-common,
rpcbind and libtirpc (compiling them is very straight forward).

Sven

-- 
"Ich fürchte mich nicht vor der Rückkehr der Faschisten in der Maske der
Faschisten, sondern vor der Rückkehr der Faschisten in der Maske der
Demokraten" (Theodor W. Adorno)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
