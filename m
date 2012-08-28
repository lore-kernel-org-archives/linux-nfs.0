Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:51041 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab2H1JAI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 05:00:08 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1T6HeZ-0001Ya-4G
	for linux-nfs@vger.kernel.org; Tue, 28 Aug 2012 11:00:07 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1T6HeY-0007UR-G9
	for linux-nfs@vger.kernel.org; Tue, 28 Aug 2012 11:00:06 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: NFS4 and quota is rpc.rquotad still needed?
Date: Tue, 28 Aug 2012 09:00:06 +0000 (UTC)
Message-ID: <k1i1am$rtl$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

unfortunately I could not find a reference to weather rpc.rquotad is still
needed for using disk-quota over NFS4 or not.

So using NFS4 what would I need to do on the server to enable quota (besides
enabling it on the underlaying filesystem of course)?

Regards

Sven

-- 
"Dynamische IP-Nummern sind Security-Homöopathie."
						(Kristian Köhntopp)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
