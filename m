From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: nvram pci card?
Date: Fri, 15 Nov 2002 09:14:10 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021115091410.A8941@ti19>
References: <00c501c28caa$2ec0c730$640a010a@winda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 209-166-240-202.cust.walrus.com.240.166.209.in-addr.arpa ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ChEp-00044o-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Nov 2002 06:14:27 -0800
To: myciel <myciel@dotcom.pl>
In-Reply-To: <00c501c28caa$2ec0c730$640a010a@winda>; from myciel@dotcom.pl on Fri, Nov 15, 2002 at 02:23:18PM +0100
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

On Fri, Nov 15, 2002 at 02:23:18PM +0100, myciel wrote:
> Do You know about any pci based nvram card? maybe somebody has already
> experiences using it with linux nfs fileserver?

IIRC, Neil Brown (kNFS and MD maintainer) did driver work for the
Micro Memory (www.umem.com) cards.  There is support in 2.4.20-rc1
(and perhaps earlier, haven't looked).  See

	Block Devices -> Micro Memory MM5415 Battery Backed RAM support

in the kernel config.

Regards,

	Bill Rugolsky


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
