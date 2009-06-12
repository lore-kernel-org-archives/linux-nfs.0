From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in
 milliseconds
Date: Fri, 12 Jun 2009 15:50:59 -0400
Message-ID: <1244836259.19533.19.camel@heimdal.trondhjem.org>
References: <200906091832.50633.agud@akamai.com>
	 <1244636844.24750.23.camel@heimdal.trondhjem.org>
	 <4A300CE3.8080502@akamai.com>
	 <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>
	 <4A316814.7030609@akamai.com>
	 <1244754888.5047.132.camel@heimdal.trondhjem.org>
	 <4A32ACDB.90802@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Amit Gud <agud@akamai.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54983 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561AbZFLTvD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 15:51:03 -0400
In-Reply-To: <4A32ACDB.90802@akamai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-12 at 12:30 -0700, Amit Gud wrote:
> We definitely want lookup caching turned on, always, including both
> positive and negative caching.  But, we need to see new files, unlinks,
> and renames much quicker than a second.

Then use the lookupcache option, since that's what it is for.

Trond

