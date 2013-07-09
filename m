Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:60442 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab3GIQEF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 12:04:05 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<sven@gegg.us>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UwaOZ-0000S8-7e
	for linux-nfs@vger.kernel.org; Tue, 09 Jul 2013 18:04:03 +0200
Received: from sven  by ultimate100.geggus.net (envelope-from
	<sven@gegg.us>)
	with local (Exim 4.72)
	id 1UwaOY-000147-JK
	for linux-nfs@vger.kernel.org; Tue, 09 Jul 2013 18:04:02 +0200
Date: Tue, 9 Jul 2013 18:03:15 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130709160315.GA4024@geggus.net>
References: <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
 <20130702080530.GA17953@geggus.net>
 <20130705181859.GA8288@fieldses.org>
 <20130705203435.GE8288@fieldses.org>
 <20130708080803.GB29990@geggus.net>
 <20130708133537.GA29071@fieldses.org>
 <20130708155406.GA7808@geggus.net>
 <20130708194144.GG29071@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130708194144.GG29071@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Montag, den 08. Juli um 21:41 Uhr:

> I'm not even sure whether it makes sense to be doing this upcall to ask
> for supplemental groups in the -1 case.  Going with the minimal fix for
> now.

Confirmed to work fine here, but strange messages from userland rpc.svcgssd persist:

Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jul  9 17:59:27 vnfsrv rpc.svcgssd[2919]: WARN: failed to free lucid sec context


> commit 8efb88340e29293e05f6b498b60596884c05a8a8

OK, is this supposed to get into 3.9.x and 3.10.x respectively?

Regards

Sven

Microsoft ist offenbar die einzige Firma, die in der Lage ist, ein mit
Office nicht kompatibles Bürosoftwarepaket einzuführen.
                            (Florian Weimer in de.alt.sysadmin.recovery)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
