From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min, max} in milliseconds
Date: Wed, 17 Jun 2009 20:37:51 +1000
Message-ID: <19000.51071.532286.805930@notabene.brown>
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
	<1245107980.7470.0.camel@heimdal.trondhjem.org>
	<4A37C8B9.2040906@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Amit Gud <agud@akamai.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51677 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749AbZFQKhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 06:37:20 -0400
In-Reply-To: message from Steve Dickson on Tuesday June 16
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday June 16, SteveD@redhat.com wrote:
> >> Wasn't this problem solved hundreds of years ago by the invention
> >> of the decimal point :-)
> >>
> >>   -o acregmin=0.0012
> >>
> >> Write the code to use as much precision as makes sense given the value
> >> of HZ - and round up.  No new mount options.
> > 
> > That works for me...
> Or better how about -o acregmin=12micro

How can you consider that to be better?
I might almost consider "12usec" a little better as it makes the unit
explicit, and it is a fairly standard abbreviation.  But I've never
seen "micro" as a suffix before.

NeilBrown
