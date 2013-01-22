Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:35660 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364Ab3AVRYH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2013 12:24:07 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Txh0x-0007rV-Py
	for linux-nfs@vger.kernel.org; Tue, 22 Jan 2013 17:47:59 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1Txh0x-0003u6-3S
	for linux-nfs@vger.kernel.org; Tue, 22 Jan 2013 17:47:59 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Hanging nfs4+krb5 mounts with negative uids?
Date: Tue, 22 Jan 2013 16:47:59 +0000 (UTC)
Message-ID: <kdmfrv$ecd$1@ultimate100.geggus.net>
References: <26b3643c253ee306d593bb4b20ff095b.squirrel@vdtoorn.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

richard@vdtoorn.nl wrote:

> Can anyone give me any help understanding why this is, or point me in a
> direction in getting this solved? I very well might have just
> misconfigured my nfsv4 + krb5 system (asking myself why am I getting
> negative uids?)

Looks like this is exactly what I ran into with vanilla Kernel 3.6.x on
debian wheezy.

It worked fine using 3.5.something and it works again using 3.7.3 after J.
Bruce Fields reverted the patch which caused the problem.

See http://marc.info/?t=135126949200001&r=1

I'm not 100% certain about the cause of this problem, but I would assume it
is because the mount is done as root which is not a valid kerberos realm (at
least in my case). However this is always the case when autofs is used
because "automount" is running as root.

Sven

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
