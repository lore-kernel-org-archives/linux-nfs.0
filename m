From: Olaf Kirch <okir@suse.de>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 13:58:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040811115831.GC12807@suse.de>
References: <4119FB15.7010205@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Burkd-0001i0-Ct
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 04:58:39 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Burkc-0004in-Vw
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 04:58:39 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <4119FB15.7010205@stams.strath.ac.uk>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, Aug 11, 2004 at 11:55:17AM +0100, Ian Thurlbeck wrote:
> System is running Fedora Core1 (2188 kernel), 3ware 7500 raid, ext3.
> I have 32 nfsd processes, running NFS V3/tcp, 8192 block size,
> single duplex 100Mbit etherpro. Clients have similar OS/mount opts.

Anyone more familiar with the Fedora kernel - does it happen
to have io barriers enabled by default?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
