From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min, max} in
 milliseconds
Date: Mon, 15 Jun 2009 16:19:40 -0700
Message-ID: <1245107980.7470.0.camel@heimdal.trondhjem.org>
References: <200906091832.50633.agud@akamai.com>
	 <1244636844.24750.23.camel@heimdal.trondhjem.org>
	 <4A300CE3.8080502@akamai.com>
	 <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>
	 <4A316814.7030609@akamai.com>
	 <1244754888.5047.132.camel@heimdal.trondhjem.org>
	 <4A32ACDB.90802@akamai.com>
	 <1244836259.19533.19.camel@heimdal.trondhjem.org>
	 <4A32CD5D.2070502@akamai.com>
	 <1244846673.32257.69.camel@heimdal.trondhjem.org>
	 <4A36D0D1.3000904@akamai.com>
	 <3786d1f06aae533fa82740d68985fd50.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Amit Gud <agud@akamai.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <steved@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35181 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbZFOXTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 19:19:45 -0400
In-Reply-To: <3786d1f06aae533fa82740d68985fd50.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-16 at 09:08 +1000, NeilBrown wrote:
> On Tue, June 16, 2009 8:53 am, Amit Gud wrote:
> > Trond Myklebust wrote:
> >> It boils down to this: I'm extremely reluctant to get into an arms race
> >> of adding ever more mount options for increasingly finer-tuned attribute
> >> cache timeouts. While such an option may meet _your_ machine room
> >> requirements here and now, it becomes tiresome over the years as
> >> machines gain power, and people first start lobbying for millisecond
> >> timeouts, then microseconds, nanoseconds, pico... in order to catch up.
> >>
> >
> > It only makes sense to make machines more powerful and put that power to
> > optimum use. If keeping up with increased resolution is an issue, you
> > think something like "-o unit=ms acregmin=..." would be better? 'unit'
> > can apply to all the time related options defaulting to seconds.
> 
> Wasn't this problem solved hundreds of years ago by the invention
> of the decimal point :-)
> 
>   -o acregmin=0.0012
> 
> Write the code to use as much precision as makes sense given the value
> of HZ - and round up.  No new mount options.

That works for me...

Trond

