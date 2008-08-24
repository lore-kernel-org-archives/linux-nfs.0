From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sun, 24 Aug 2008 15:19:56 -0400
Message-ID: <1219605596.14389.5.camel@localhost>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
	 <1219440202.9097.14.camel@localhost>
	 <1219441041.27921.57.camel@localhost.localdomain>
	 <1219442213.9097.25.camel@localhost>
	 <1219603981.27921.145.camel@localhost.localdomain>
	 <1219605422.14389.2.camel@localhost>
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
Received: from mail-out2.uio.no ([129.240.10.58]:53750 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044AbYHXTUD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Aug 2008 15:20:03 -0400
In-Reply-To: <1219605422.14389.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-08-24 at 15:17 -0400, Trond Myklebust wrote:
> >From the tcpdump, it looks as if the NFS server is failing to close the
> socket, when the client closes its side. You therefore end up getting
> stuck in the FIN_WAIT2 state (as netstat clearly shows above).

BTW: the RPC client is closing the socket because it detected no NFS
activity for 5 minutes. Did you expect any NFS activity during this
time?

Trond

