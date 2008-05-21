From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] usb-storage: don't call utsname()
Date: Wed, 21 May 2008 11:09:57 -0700
Message-ID: <20080521180957.GA17598@kroah.com>
References: <20080521123700.GA8770@infradead.org> <Pine.LNX.4.44L0.0805211349480.3409-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Adrian Bunk <bunk@kernel.org>,
	USB Storage list <usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>,
	systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-cifs-client@lists.samba.org, linux-nfs@vger.kernel.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57259 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932579AbYEUSKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 14:10:34 -0400
In-Reply-To: <Pine.LNX.4.44L0.0805211349480.3409-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2008 at 01:51:17PM -0400, Alan Stern wrote:
> This patch (as1100) replaces the core-kernel function call to utsname()
> in usb-storage with the UTS_RELEASE macro.  It's used only for warning
> about extra unusual_devs entries.
> 
> Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>

Why?  With this change, if you change the version number, the file will
have to be rebuilt.  Without the change, the file will not need to be
rebuilt, right?

I thought that was why this change was made a while ago, to prevent
things from having to be rebuilt that didn't need to be.

thanks,

greg k-h
