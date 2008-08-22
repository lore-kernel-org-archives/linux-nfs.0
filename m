From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 14:23:22 -0700
Message-ID: <1219440202.9097.14.camel@localhost>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:46099 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753508AbYHVVXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Aug 2008 17:23:32 -0400
In-Reply-To: <1219435207.27921.51.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-22 at 21:00 +0100, Ian Campbell wrote:
> On Fri, 2008-08-22 at 12:33 -0700, John Ronciak wrote:
> > On Fri, Aug 22, 2008 at 11:13 AM, Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org> wrote:
> > 
> > >> That's probably also a networking device driver issue candidate: your
> > >> RPC task is queued up waiting to be sent.
> > >>
> > >> What networking card+device driver are you using here?
> > >
> > > # ethtool -i eth0
> > > driver: e1000
> > > version: 7.3.20-k2-NAPI
> > > firmware-version: N/A
> > > bus-info: 0000:01:0a.0
> > There is nothing indicating that the NIC/driver is causing any sort of
> > problem here, at least not with what has been presented so far.  When
> > the NFS mount isn't working is the networking still active and
> > working?
> 
> So far as I can tell, yes. I can login via ssh so long as the user
> doesn't have NFS $HOME, I haven't tried much else and the box isn't
> locked up at the moment, I'd bet it's fine though.

...and the server? Something is preventing that RPC payload from being
delivered...

Trond

