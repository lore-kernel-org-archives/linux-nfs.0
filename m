From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sun, 24 Aug 2008 15:17:02 -0400
Message-ID: <1219605422.14389.2.camel@localhost>
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
Received: from mail-out2.uio.no ([129.240.10.58]:38390 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbYHXTRM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Aug 2008 15:17:12 -0400
In-Reply-To: <1219603981.27921.145.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-08-24 at 19:53 +0100, Ian Campbell wrote:
> On Fri, 2008-08-22 at 14:56 -0700, Trond Myklebust wrote:
> > On Fri, 2008-08-22 at 22:37 +0100, Ian Campbell wrote:
> > > I can ssh to the server fine. The same server also serves my NFS home
> > > directory to the box I'm writing this from and I've not seen any trouble
> > > with this box at all, it's a 2.6.18-xen box.
> > 
> > OK... Are you able to reproduce the problem reliably?
> > 
> > If so, can you provide me with a binary tcpdump or wireshark dump? If
> > using tcpdump, then please use something like
> > 
> >    tcpdump -w /tmp/dump.out -s 90000 host myserver.foo.bar and port 2049
> > 
> > Please also try to provide a netstat dump of the current TCP connections
> > as soon as the hang occurs:
> > 
> >   netstat -t
> 
> Aug 24 18:08:59 iranon kernel: [168839.556017] nfs: server hopkins not responding, still trying
> but I wasn't around until 19:38 to spot it.
> 
> netstat when I got to it was:
> 
> Proto Recv-Q Send-Q Local Address           Foreign Address         State      
> tcp        0      0 localhost.localdo:50891 localhost.localdom:6543 ESTABLISHED
> tcp        1      0 iranon.hellion.org.:ssh azathoth.hellion.:52682 CLOSE_WAIT 
> tcp        0      0 localhost.localdom:6543 localhost.localdo:50893 ESTABLISHED
> tcp        0      0 iranon.hellion.org.:837 hopkins.hellion.org:nfs FIN_WAIT2  
> tcp        0      0 localhost.localdom:6543 localhost.localdo:41831 ESTABLISHED
> tcp        0      0 localhost.localdo:13666 localhost.localdo:59482 ESTABLISHED
> tcp        0      0 localhost.localdo:34288 localhost.localdom:6545 ESTABLISHED
> tcp        0      0 iranon.hellion.org.:ssh azathoth.hellion.:48977 ESTABLISHED
> tcp        0      0 iranon.hellion.org.:ssh azathoth.hellion.:52683 ESTABLISHED
> tcp        0      0 localhost.localdom:6545 localhost.localdo:34288 ESTABLISHED
> tcp        0      0 localhost.localdom:6543 localhost.localdo:50891 ESTABLISHED
> tcp        0      0 localhost.localdo:50893 localhost.localdom:6543 ESTABLISHED
> tcp        0      0 localhost.localdo:41831 localhost.localdom:6543 ESTABLISHED
> tcp        0     87 localhost.localdo:59482 localhost.localdo:13666 ESTABLISHED
> tcp        1      0 localhost.localdom:6543 localhost.localdo:41830 CLOSE_WAIT 
> 
> (iranon is the problematic host .4, azathoth is my desktop machine .5, hopkins is the NFS server .6)
> 
> tcpdumps are pretty big. I've attached the last 100 packets captured. If
> you need more I can put the full file up somewhere.
> 
> -rw-r--r-- 1 root   root   1.3G Aug 24 17:57 dump.out0
> -rw-r--r-- 1 root   root   536M Aug 24 19:38 dump.out1
> 
> Ian.

>From the tcpdump, it looks as if the NFS server is failing to close the
socket, when the client closes its side. You therefore end up getting
stuck in the FIN_WAIT2 state (as netstat clearly shows above).

Is the server keeping the client in this state for a very long period?

Cheers
  Trond

