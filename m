From: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Subject: Re: [NFS] Redhat WS4 mount default changed to tcp ?
Date: Mon, 14 Jan 2008 12:22:44 -0500
Message-ID: <478B9A64.5030903@bnl.gov>
References: <478B90A1.5000900@bnl.gov>
	<1200330387.7470.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37138 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753489AbYANR36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 12:29:58 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JET8F-0008IE-Vj
	for linux-nfs@vger.kernel.org; Tue, 15 Jan 2008 04:29:56 +1100
In-Reply-To: <1200330387.7470.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2008-01-14 at 11:41 -0500, Sev Binello wrote:
>   
>> Does anyone know the reason Redhat changed the default mount protocol to 
>> tcp ?
>>     
>
> It is a more robust protocol than UDP, specially when you are using
> large values for rsize/wsize (by 'large' I mean 'significantly greater
> than the MTU for your network').
>
>   
Wasn't that always the case ? Was wondering Why now ?
>> Can anything be inferred from this change ?
>> Should we be mounting file systems  tcp now ?
>>     
>
> If you have no performance problems with UDP, then by all means keep
> using it...
>
> Cheers
>   Trond
>
>   


-- 

Sev Binello
Brookhaven National Laboratory
Upton, New York
631-344-5647
sev-IGkKxAqZmp0@public.gmane.org


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

