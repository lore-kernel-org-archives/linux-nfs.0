From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] usb-storage: don't call utsname()
Date: Wed, 21 May 2008 14:52:51 -0400
Message-ID: <20080521185251.GA783@infradead.org>
References: <20080521123700.GA8770@infradead.org> <Pine.LNX.4.44L0.0805211349480.3409-100000@iolanthe.rowland.org> <20080521180957.GA17598@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Adrian Bunk <bunk@kernel.org>,
	USB Storage list <usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>,
	systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-cifs-client@lists.samba.org, linux-nfs@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40242 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936405AbYEUSxK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 14:53:10 -0400
In-Reply-To: <20080521180957.GA17598@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2008 at 11:09:57AM -0700, Greg KH wrote:
> Why?  With this change, if you change the version number, the file will
> have to be rebuilt.  Without the change, the file will not need to be
> rebuilt, right?

Because thanks to the container patches it utsname fields other than
hostname can actually change at runtime now and you'll get races looking
at them.  And probably not the output you want if someone in your
container changes the kernel version to trick applications.
