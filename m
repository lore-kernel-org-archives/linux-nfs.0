From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems
Date: Thu, 14 Nov 2002 18:23:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021114182320.K20258@redhat.com>
References: <200211142033.gAEKXGHe010083@pookie.nersc.gov> <3DD42E26.A603AD36@amis.com> <20021114181149.J20258@redhat.com> <3DD4305B.D439C6CD@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: canon@pookie.nersc.gov,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CTKX-0007Dd-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 15:23:25 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3DD4305B.D439C6CD@amis.com>; from ewhiting@amis.com on Thu, Nov 14, 2002 at 04:23:07PM -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Nov 14, 2002 at 04:23:07PM -0700, Eric Whiting wrote:
> Both of these NICs seemed to have the same behavior.
> <6>eth0: Intel(R) PRO/1000 Network Connection
> <6>eth1: NetGear GA620 Gigabit Ethernet at 0xea060000, irq 11
> 
> Yes -- I'm running on a 32bit/33Mhz bus right now. I do have a Sun 280R
> with a 64bit/66Mhz card in a 66Mhz slot that doesn't even seem to
> support jumbo frames at all.

I'd guess you're hitting the PCI bandwidth limitations then, as the larger 
packets permit greater throughput, which in turn drives up bus utilizations.  
If you've got any disk controllers on the same bus, that would definately 
explain the problem (or any other devices on the bus that are in use).

		-ben


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
