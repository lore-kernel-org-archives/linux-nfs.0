Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:43959 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964849Ab3FTIit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jun 2013 04:38:49 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UpZqY-0002JS-5P
	for linux-nfs@vger.kernel.org; Thu, 20 Jun 2013 10:03:58 +0200
Date: Thu, 20 Jun 2013 10:03:55 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130620080354.GA5591@geggus.net>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
 <20130619213412.GA2547@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130619213412.GA2547@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Mittwoch, den 19. Juni um 23:34 Uhr:

> Apologies, I don't remember the previous discussion, so, could you
> summarize for me?

Shure!
My original bug-report ist here:
http://www.spinics.net/lists/linux-nfs/msg37454.html

> - you're able to reproduce/not reproduce the problem by changing
>   *only* the kernel on the nfs server between 3.8.x and
>   3.10.0-rc2 ?

Exactly. See also the Postings of Richard van den Toorn on the list.

Summary: Mount is locking when upgrading from 3.8.x to 3.9.x

Unfortunately I was unable to do a git bisect because somewhere on the way
the behaviour changed from locking to "permission denied".

If you give me a hint if this behaviour should be marked as good or bad I
can continue bisecting!

> - have you figured out exactly where the failure happens?:

No because I have not been able to do git bisect to the end.

> - which version of NFS are you using?

NFS4 with Kerberos authentication.

> Also if you haven't already it would be useful to know at exactly which
> step of the process it's failing.  As a first step running wireshark on
> the traffic between client and server and looking for a NULL
> init_sec_context rpc call and seeing whether it succeeds or not, would
> be useful.

I already posted a wireshark dump:
http://www.spinics.net/lists/linux-nfs/msg37472.html

Regards

Sven

-- 
"Ich fürchte mich nicht vor der Rückkehr der Faschisten in der Maske der
Faschisten, sondern vor der Rückkehr der Faschisten in der Maske der
Demokraten" (Theodor W. Adorno)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
