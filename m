From: Olaf Kirch <okir@suse.de>
Subject: Re: ReasmFails increases / NFS performance on Linux Cluster
Date: Sat, 14 Aug 2004 11:23:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040814092339.GB28329@suse.de>
References: <001501c481d2$d8900950$6701a8c0@psyche1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvulN-0004j2-0x
	for nfs@lists.sourceforge.net; Sat, 14 Aug 2004 02:23:45 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BvulM-0000nV-KN
	for nfs@lists.sourceforge.net; Sat, 14 Aug 2004 02:23:44 -0700
To: Patrice Seyed <apseyed@bu.edu>
In-Reply-To: <001501c481d2$d8900950$6701a8c0@psyche1>
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

On Sat, Aug 14, 2004 at 03:46:44AM -0400, Patrice Seyed wrote:
> I welcome any suggestions or recommendations.

Try using NFS over TCP, or, if all your NICs support it, use jumbograms
to avoid fragmentation.

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
