From: Christian Reis <kiko@async.com.br>
Subject: Re: General network slowness on SIS 530 with eepro100
Date: Thu, 15 Aug 2002 16:21:55 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020815162155.L30462@blackjesus.async.com.br>
References: <20020813212923.L2219@blackjesus.async.com.br> <200208150844.g7F8iQp19827@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eepro100@scyld.com, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from calhau.terra.com.br ([200.176.3.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fQCC-0002Wb-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 12:22:13 -0700
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200208150844.g7F8iQp19827@Port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Thu, Aug 15, 2002 at 11:41:20AM -0200
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thu, Aug 15, 2002 at 11:41:20AM -0200, Denis Vlasenko wrote:
> On 13 August 2002 22:29, Christian Reis wrote:
> > On tri, which is the referred SIS530 box, as you can see, for most runs
> > the CPU usage is just so much higher than minas, which has practically
> > the same setup: K6-500, old PCI (no AGP) board, eepro100 card. I'm
> > wondering if anybody has seen something like this before?
> 
> Start swapping hardware between these two boxes

I've done it, actually. I've swapped processor, memory and video cards
(which are the only things the boxes actually contain) and there has
been no change. It's very strange - block read and block write consume
enormous amounts of CPU, no matter how much I tinker. I've tried 2.4.19,
2.2.21, NFS patches, etc. 

There could be a hidden BIOS option, but I can't seem to find out what
it is. Both caches are enabled. PCI interrupts are fine. It has to be a
motherboard support problem; in Windows the box runs fine. :-(

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
