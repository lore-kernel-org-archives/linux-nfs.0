Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:39759 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757389Ab2JaMwp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Oct 2012 08:52:45 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TTXml-0005EE-Uq
	for linux-nfs@vger.kernel.org; Wed, 31 Oct 2012 13:52:44 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1TTXml-00045b-Ac
	for linux-nfs@vger.kernel.org; Wed, 31 Oct 2012 13:52:43 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Date: Wed, 31 Oct 2012 12:52:43 +0000 (UTC)
Message-ID: <k6r6ur$eva$2@ultimate100.geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net> <20121026171549.GA11806@fieldses.org> <20121029094038.GA14836@geggus.net> <20121029150203.GB9502@fieldses.org> <20121029163323.GA24345@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

>> I'd be curious to understand what changed on the server to make a
>> difference. 
> 
> Nothing but the kernel. I'm currently dual booting either 3.5.7 or 3.6.3
> vanilla kernels on the same system.

I did some further investigation on this using a freshly installed
system on virtualbox with either kernel.

Same odd behaviour. Everything work using Kernel 3.5.7. Server does not work using
Kernel 3.6.3.

There are even different filesystems on the vm (ext4) and on the real server
(xfs).

Looks like I need to cherry-pick nfs4 server changes between 3.5.7 and 3.6.3 now :(

Regards

Sven

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
