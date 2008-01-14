From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Redhat WS4 mount default changed to tcp ?
Date: Mon, 14 Jan 2008 12:06:27 -0500
Message-ID: <1200330387.7470.11.camel@heimdal.trondhjem.org>
References: <478B90A1.5000900@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44013 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbYANRHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 12:07:17 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JESmG-0008EH-Ku
	for linux-nfs@vger.kernel.org; Tue, 15 Jan 2008 04:07:12 +1100
In-Reply-To: <478B90A1.5000900-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-14 at 11:41 -0500, Sev Binello wrote:
> Does anyone know the reason Redhat changed the default mount protocol to 
> tcp ?

It is a more robust protocol than UDP, specially when you are using
large values for rsize/wsize (by 'large' I mean 'significantly greater
than the MTU for your network').

> Can anything be inferred from this change ?
> Should we be mounting file systems  tcp now ?

If you have no performance problems with UDP, then by all means keep
using it...

Cheers
  Trond


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

