From: Amit Gud <agud@akamai.com>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
Date: Mon, 15 Jun 2009 15:53:05 -0700
Message-ID: <4A36D0D1.3000904@akamai.com>
References: <200906091832.50633.agud@akamai.com>	 <1244636844.24750.23.camel@heimdal.trondhjem.org>	 <4A300CE3.8080502@akamai.com>	 <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>	 <4A316814.7030609@akamai.com>	 <1244754888.5047.132.camel@heimdal.trondhjem.org>	 <4A32ACDB.90802@akamai.com>	 <1244836259.19533.19.camel@heimdal.trondhjem.org>	 <4A32CD5D.2070502@akamai.com> <1244846673.32257.69.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from prod-mail-xrelay04.akamai.com ([96.6.114.79]:56099 "EHLO
	prod-mail-xrelay04.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbZFOWwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 18:52:41 -0400
In-Reply-To: <1244846673.32257.69.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> It boils down to this: I'm extremely reluctant to get into an arms race
> of adding ever more mount options for increasingly finer-tuned attribute
> cache timeouts. While such an option may meet _your_ machine room
> requirements here and now, it becomes tiresome over the years as
> machines gain power, and people first start lobbying for millisecond
> timeouts, then microseconds, nanoseconds, pico... in order to catch up.
> 

It only makes sense to make machines more powerful and put that power to
optimum use. If keeping up with increased resolution is an issue, you
think something like "-o unit=ms acregmin=..." would be better? 'unit'
can apply to all the time related options defaulting to seconds.


AG
-- 
May the source be with you.
http://cis.ksu.edu/~gud
