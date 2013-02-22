Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:49230 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754780Ab3BVI5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 03:57:08 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1U8oRF-0000Nj-SZ
	for linux-nfs@vger.kernel.org; Fri, 22 Feb 2013 09:57:06 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1U8oRD-0002gF-V0
	for linux-nfs@vger.kernel.org; Fri, 22 Feb 2013 09:57:04 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4: "Value too large for defined data type" problem
Date: Fri, 22 Feb 2013 08:57:03 +0000 (UTC)
Message-ID: <kg7bsv$a1f$1@ultimate100.geggus.net>
References: <kfkvll$adm$1@ultimate100.geggus.net> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3DA465@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> If your applications are unable to cope with 64-bit inode numbers, then
> you can turn back on the inode number mapping on the nfs client:
> 
> echo "options nfs enable_ino64=N" >/etc/modprobe.d/options-local.conf

Thanks, works fine.

Sven

-- 
Das allgemeine Persönlichkeitsrecht (Art. 2 Abs.1 i.V.m. Art.1 Abs. 1GG)
umfasst das Grundrecht auf Gewährleistung der Vertraulichkeit und Integrität
informationstechnischer Systeme. (BVerfG, 1BvR 370/07)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
