Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:59354 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab3GJHza (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jul 2013 03:55:30 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UwpFJ-0004RP-7b
	for linux-nfs@vger.kernel.org; Wed, 10 Jul 2013 09:55:29 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1UwpFF-00068Q-Jx
	for linux-nfs@vger.kernel.org; Wed, 10 Jul 2013 09:55:25 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Date: Wed, 10 Jul 2013 07:55:25 +0000 (UTC)
Message-ID: <krj41d$n0s$1@ultimate100.geggus.net>
References: <20130620144955.GB11728@fieldses.org> <20130620145209.GC11728@fieldses.org> <20130621083221.GA4103@geggus.net> <20130624215408.GD23596@fieldses.org> <20130625094612.GA2186@geggus.net> <20130701205234.GF19945@fieldses.org> <20130702080530.GA17953@geggus.net> <20130705181859.GA8288@fieldses.org> <20130705203435.GE8288@fieldses.org> <20130708080803.GB29990@geggus.net> <20130709165726.GD8281@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

>> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
>> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: WARN: failed to free lucid sec context
> 
> Does rpc.svcgssd still need fixing?  (Sven, could you remind us what
> nfs-utils version this is from?)

1.2.8

Regards

Sven

-- 
"Thinking of using NT for your critical apps?
                                  Isn't there enough suffering in the world?"
                   (Advertisement of Sun Microsystems in Wall Street Journal)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
