From: "H . J . Lu" <hjl@lucon.org>
Subject: Re: RedHat 7.3 crashed NetApp?
Date: Fri, 17 May 2002 08:11:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020517081125.A5553@lucon.org>
References: <C0B72BFE4E6CFF4C97FDB17BED66E84A085DB7@cceexc15.americas.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178jOG-0001RW-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 08:11:32 -0700
To: "Cooke, Alan" <acooke@hp.com>
In-Reply-To: <C0B72BFE4E6CFF4C97FDB17BED66E84A085DB7@cceexc15.americas.cpqcorp.net>; from acooke@hp.com on Fri, May 17, 2002 at 08:14:37AM -0500
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

On Fri, May 17, 2002 at 08:14:37AM -0500, Cooke, Alan wrote:
> While running the 2.4.18-4smp kernel (RedHat), and testing NFS3, our NetApp filer running OnTap 6.1.1R2 experienced massive incoming traffic from the Linux client in question. The Linux client required rebooting. We have been able to repeat this behavior, and are suspicious of the network driver on the Linux client which is using the eth0 driver. A
> 

I think it is the same as what happened to me. I had to reboot/unplug
my Linux client before the whole NFS network went down. I am using Intel
e100 driver on eepro100. But my Linux NFS severs have no problem with
that client.


H.J.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
