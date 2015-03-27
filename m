Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:35166 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbbC0Qoe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:44:34 -0400
Date: Fri, 27 Mar 2015 17:08:25 +0100
From: Sander Smeenk <ssmeenk@freshdot.net>
To: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd reads /etc/mtab 17028 times, 100% CPU.
Message-ID: <20150327160825.GE26088@dot.freshdot.net>
References: <20150325093707.GC26088@dot.freshdot.net>
 <55143B19.3090003@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55143B19.3090003@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Steve Dickson (SteveD@redhat.com):

> > This entire process of reading /etc/mtab 17028 times takes a lot of
> > time during which the client stalls, but in the end 'it just works
> > fine'. It just takes ages when you try to tab-complete on a client.
> Taking a quick look... it appears the only way rpc.mountd will read
> /etc/mtab is if the 'crossmnt' export flag is set. Is this the case?

Yes.

IIRC this was necessary for this situation:
Server has filesytems mounted on /mnt/pt1 and /mnt/pt1/foo.
Both /mnt/pt1 and /mnt/pt1/foo are exported with 'crossmnt'.
Clients that mount just /mnt/pt1 can also reach /mnt/pt1/foo.


> > Could someone point me to the code that is involved in doing this?
> utils/mountd/cache.c:nfsd_fh():path = next_mnt(&mnt, exp->m_export.e_path);

Thanks. I'll dig around some more and see what i can find.


-Sndr.
-- 
| What are the little plastic endings on your shoelaces called?
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
