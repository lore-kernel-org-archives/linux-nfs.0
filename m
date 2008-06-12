From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Server-side locking issue
Date: Thu, 12 Jun 2008 18:42:49 -0400
Message-ID: <4851A669.3020600@gmail.com>
References: <20080508221815.GB4583@async.com.br>	<20080509154305.GA798@fieldses.org>
	<20080612214340.GA17293@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS@lists.sourceforge.net, Ronaldo Maia <romaia-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
To: Christian Robottom Reis <kiko@canonical.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48540 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642AbYFLWju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 18:39:50 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K6vSO-0005BR-0w
	for linux-nfs@vger.kernel.org; Fri, 13 Jun 2008 08:39:48 +1000
In-Reply-To: <20080612214340.GA17293-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christian Robottom Reis wrote:
> On Fri, May 09, 2008 at 11:43:05AM -0400, J. Bruce Fields wrote:
>
>   
>> Perhaps a sysrq-T dump of lockd would show where (and whether) it's
>> blocked?  (So once lockd stops responding, log into the server, run
>> "echo t >/proc/sysrq-trigger", and collect the output from the logs,
>> especially the stacktrace for the lockd process).
>>     
Sorry, I was debugging some other stuffs on my screen while mindlessly 
reading the mailing list - somehow missed Bruce's original "sysrq-t" 
paragraph. However, look like you've missed the "w" part. My guess is 
that the lockd was spinning on the CPU when you hit the sysrq-t key or 
your sysrq-t didn't run to its completion at all.

-- Wendy

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

