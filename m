Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934181AbbGVPkc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 11:40:32 -0400
Date: Wed, 22 Jul 2015 11:40:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Parallel file locking quite slow with vers=4.0 compared to vers=3
Message-ID: <20150722154031.GI22718@fieldses.org>
References: <55ACFF59.7040707@bio.ifi.lmu.de>
 <20150720212305.GB11050@fieldses.org>
 <55ADEA5C.8020607@bio.ifi.lmu.de>
 <20150721155144.GC11050@fieldses.org>
 <55AFAD60.7040607@bio.ifi.lmu.de>
 <55AFAE57.7050409@bio.ifi.lmu.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55AFAE57.7050409@bio.ifi.lmu.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 04:53:11PM +0200, Frank Steiner wrote:
> Frank Steiner wrote
> 
> > Thanks! I tried your patch and it goes way faster. The last 2 or 3
> > of 20 xterms that I start in parallel still take about 1-3 seconds,
> > but the rest is poping up immediately. NFS3 is still better as it
> 
> The difference is still quite large when killing the xterms again. 
> "killall xterm" on NFSv3 takes half a second, on NFSv4 the last
> about 5 xterms are delayed and vanish one after another, the last one
> about 5-6 seconds after the killall was started.

No idea what's going on there.

--b.
