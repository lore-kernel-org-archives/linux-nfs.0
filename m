Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:60292 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab2FSTRz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 15:17:55 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Sh3vw-0002NS-En
	for linux-nfs@vger.kernel.org; Tue, 19 Jun 2012 21:17:48 +0200
Received: from p5dc13a15.dip.t-dialin.net ([93.193.58.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 21:17:48 +0200
Received: from ponto by p5dc13a15.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 21:17:48 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <ponto@pontohonk.de>
Subject: Re: Spurious permission denied
Date: Tue, 19 Jun 2012 20:23:37 +0200
Message-ID: <9ms6b9-idk.ln1@homer.bruehl.pontohonk.de>
References: <43v5b9-ifa.ln1@barney.bruehl.pontohonk.de> <1340113184.3754.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

> 
> NFSv3 doesn't use the mode bits to determine access rights, so looking
> at a GETATTR call isn't really that helpful. You need to catch the
> original ACCESS call and reply in order to figure out what caused the
> permission denied issue.

Hmm.

I started capturing the packets before I tried the ls and stopped some 
seconds after ls.

These were the only three packets wireshark captured. 

I wait till the problem occurs again and try to get more meaningful packets.

Thanks
Christoph

