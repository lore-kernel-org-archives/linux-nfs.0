Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:41443 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542Ab2HUIsx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 04:48:53 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T3jlm-0007P0-LB
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 10:25:02 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T3jll-0006BL-W1
	for linux-nfs@vger.kernel.org; Tue, 21 Aug 2012 10:25:02 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: NFS4: ssh + unlink(~/.Xauthority) delays
Date: Tue, 21 Aug 2012 08:25:01 +0000 (UTC)
Message-ID: <k0vgkt$mm0$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm about to setup a Linux based fileserver for home directories and a
couple of Linux clients with kerberos and NFS4 (no NFS3 for security
reasons).

The whole stuff is currently based on debian stable (with a backported
current NFS userland 1.2.5) and a recent vanilla kernel (3.5.2).

So far I have the NFS4 Server up and running as well as a couple of clients
with NFS4+autofs mounted home directories.

All this stuff mostly works now, but unfortunately I ran into some strange
bahaviour now.

When I ssh from one machine to another the system hangs (a delay of up to 60
seconds) while running xauth.

Replacing xauth by a wrapper script I have been able to trace this behaviour
to a hang of an unlink("/home/<user>/.Xauthority") system call.

So the question is what cases hangs in NFS4 based Linux systems in general
an in this particular case?

Any hint on how to debug this?

Sven

-- 
"C Is Quirky, Flawed, And An Enormous Success."
(Dennis M. Ritchie)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
