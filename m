From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] usb-storage: don't call utsname()
Date: Wed, 21 May 2008 12:35:17 -0700
Message-ID: <20080521193517.GA4905@kroah.com>
References: <20080521123700.GA8770@infradead.org> <Pine.LNX.4.44L0.0805211349480.3409-100000@iolanthe.rowland.org> <20080521180957.GA17598@kroah.com> <20080521185251.GA783@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Adrian Bunk <bunk@kernel.org>,
	USB Storage list <usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>,
	systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-cifs-client@lists.samba.org, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55286 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936957AbYEUTfm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 15:35:42 -0400
In-Reply-To: <20080521185251.GA783@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2008 at 02:52:51PM -0400, Christoph Hellwig wrote:
> On Wed, May 21, 2008 at 11:09:57AM -0700, Greg KH wrote:
> > Why?  With this change, if you change the version number, the file will
> > have to be rebuilt.  Without the change, the file will not need to be
> > rebuilt, right?
> 
> Because thanks to the container patches it utsname fields other than
> hostname can actually change at runtime now and you'll get races looking
> at them.  And probably not the output you want if someone in your
> container changes the kernel version to trick applications.

So, do we now go and rip out all usages of utsname()->release and put
back the #define just because of the loonacy of containers?

No kernel should have to change it's version number to trick an
application, why would an application care about the version number to
start with?  In the "enterprise kernel" world, version numbers have
little to no relevance on the functionality or features of the kernel,
so any check of something like this is sure to be wrong to start with.

thanks,

greg k-h
