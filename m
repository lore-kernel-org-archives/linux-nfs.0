Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:58409 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048Ab2FTMzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 08:55:43 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1ShKRf-0002eQ-7M
	for linux-nfs@vger.kernel.org; Wed, 20 Jun 2012 14:55:39 +0200
Received: from bg-1.or.uni-bonn.de ([131.220.141.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 14:55:39 +0200
Received: from bartoschek by bg-1.or.uni-bonn.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 14:55:39 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <bartoschek@gmx.de>
Subject: Re: 3.0+ NFS issues
Date: Wed, 20 Jun 2012 14:52:01 +0200
Message-ID: <hkt8b9-4hi.ln1@barney.bruehl.pontohonk.de>
References: <4FBF2C57.3070203@msgid.tls.msk.ru> <20120529152416.GC3441@fieldses.org> <4FC5C82E.4020806@msgid.tls.msk.ru> <20120530132518.GA13794@fieldses.org> <4FC713ED.5040807@msgid.tls.msk.ru> <1338469169.2420.7.camel@lade.trondhjem.org> <4FC77128.9090206@msgid.tls.msk.ru> <1338471975.7732.5.camel@lade.trondhjem.org> <4FC77755.5060606@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> In 2 places the server stops responding. In both cases, the client seems
>> to be sending a single TCP frame containing several COMPOUNDS containing
>> READ requests (which should be legal) just prior to the hang. When the
>> server doesn't respond, the client pings it with a RENEW, before it ends
>> up severing the TCP connection and then retransmitting.
> 
> And sometimes -- speaking only from the behavour I've seen, not from the
> actual frames sent -- server does not respond to the RENEW too, in which
> case the client reports "nfs server no responding", and on the next
> renew it may actually respond.  This happens too, but much more rare.
> 
> During these stalls, ie, when there's no network activity at all,
> the server NFSD threads are busy eating all available CPU.
> 
> What does it all tell us? :)

Hi,

are there news on this issue? We see bad NFS performance on systems using 
Ubuntu 12.04 compared to systems using Ubuntu 10.04 that look similar.

There are also two bug reports for Ubuntu with some information:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1006446
https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/879334

Chrsitoph

