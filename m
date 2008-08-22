From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 14:56:53 -0700
Message-ID: <1219442213.9097.25.camel@localhost>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
	 <1219440202.9097.14.camel@localhost>
	 <1219441041.27921.57.camel@localhost.localdomain>
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
Received: from mail-out1.uio.no ([129.240.10.57]:43463 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbYHVV5B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Aug 2008 17:57:01 -0400
In-Reply-To: <1219441041.27921.57.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-08-22 at 22:37 +0100, Ian Campbell wrote:
> I can ssh to the server fine. The same server also serves my NFS home
> directory to the box I'm writing this from and I've not seen any trouble
> with this box at all, it's a 2.6.18-xen box.

OK... Are you able to reproduce the problem reliably?

If so, can you provide me with a binary tcpdump or wireshark dump? If
using tcpdump, then please use something like

   tcpdump -w /tmp/dump.out -s 90000 host myserver.foo.bar and port 2049

Please also try to provide a netstat dump of the current TCP connections
as soon as the hang occurs:

  netstat -t

Cheers
  Trond

