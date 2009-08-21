From: Simon Kirby <sim@hostway.ca>
Subject: Re: NFS v3 cached directory content out of sync
Date: Fri, 21 Aug 2009 12:15:11 -0700
Message-ID: <20090821191511.GB29380@hostway.ca>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com> <1250880591.27154.18.camel@heimdal.trondhjem.org> <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:42141 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751175AbZHUTPL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 15:15:11 -0400
In-Reply-To: <d4098e2f0908211208j55dee16fy146ddb8de81d8722-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 21, 2009 at 09:08:01PM +0200, Stefan Egli wrote:

> >> ?Question 4: If we'd somehow manually detected such a directory
> >> content inconsistency - would there be something like a 'hey NFS
> >> client, flush all NFS caches NOW' thing?
> >
> > No.
> 
> unmount / mount would - but that's obviously not feasible. bugger
> there's nothing for that...

Wouldn't (admittedly sledgehammer) echo 3 > /proc/sys/vm/drop_caches
accomplish this?

Simon-
