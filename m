Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:36100 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab2LLLPa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 06:15:30 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TikHh-0003J6-Fw
	for linux-nfs@vger.kernel.org; Wed, 12 Dec 2012 12:15:29 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1TikHf-00026v-7R
	for linux-nfs@vger.kernel.org; Wed, 12 Dec 2012 12:15:27 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Date: Wed, 12 Dec 2012 11:15:27 +0000 (UTC)
Message-ID: <ka9p0f$7nc$1@ultimate100.geggus.net>
References: <20121109200730.GI6171@fieldses.org> <E1TWxKX-00025I-J2@diesel.geggus.net> <20121109232410.GK6171@fieldses.org> <20121112091717.GA1610@geggus.net> <20121113224005.GA11545@fieldses.org> <20121114005815.GA23604@fieldses.org> <20121114160712.GG23604@fieldses.org> <20121114160808.GH23604@fieldses.org> <20121115165823.GA5505@geggus.net> <20121116191934.GA6358@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

>> OK, so this can be marked as resolved (for now) on my todo list, right? Will
>> this go into 3.6.7 and of course 3.7?
> 
> Yep, I'll pass this along by next week.

As 3.7 has been relased now:

It looks like the unreverted Version is still present in Linux 3.7.0 as well
as 3.6.10

While it is easy enough to use
"git revert bbf43dc888833ac0539e437dbaeb28bfd4fbab9f" I would rather be able
to use vanilla kernels again.

Regards

Sven

-- 
Das Internet wird vor allem von Leuten genutzt, die sich Pornografie
ansehen, während sie Bier trinken, es ist daher für Wahlen nicht
geeignet (Jaroslaw Kaczynski)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
