From: Greg KH <greg@kroah.com>
Subject: Re: [stable] Linux 2.6.27.13
Date: Wed, 28 Jan 2009 16:37:12 -0800
Message-ID: <20090129003712.GC23732@kroah.com>
References: <20090125004823.GA6711@kroah.com> <4980565E.3000800@krogh.cc> <1233171227.9785.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, autofs-CPWUtch7KCBzeIdxy0IIJw@public.gmane.org,
	linux-nfs@vger.kernel.org, Greg KH <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35242 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753360AbZA2BDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 20:03:30 -0500
In-Reply-To: <1233171227.9785.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 28, 2009 at 02:33:47PM -0500, Trond Myklebust wrote:
> On Wed, 2009-01-28 at 13:58 +0100, Jesper Krogh wrote:
> > Greg KH wrote:
> > > We (the -stable team) are announcing the release of the 2.6.27.13
> > > kernel.
> > > 
> > > It contains a wide range of bugfixes, and all users of the 2.6.27 kernel
> > > series are strongly encouraged to upgrade.
> > > 
> > > I'll also be replying to this message with a copy of the patch between
> > > 2.6.27.12 and 2.6.27.13
> > 
> > Still on a 2.6.27.6  I got this on an NFS client while restarting the 
> > NFS-server at the other end. Seems autofs/nfs releated.
> > 
> > 
> > [6367172.212954] ------------[ cut here ]------------
> > [6367172.213122] kernel BUG at net/sunrpc/rpcb_clnt.c:498!
> 
> Already fixed in 2.6.28 by the following commit.
>   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=9a4bd29fe8f6d3f015fe1c8e5450eb62cfebfcc9
> 
> You should probably also apply the following commit (also in 2.6.28),
> which fixes a memory leak in the same area.
>   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=96165e2b7c4e2c82a0b60c766d4a2036444c21a0

Thanks for letting me know, I'll queue them up.

greg k-h
