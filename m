From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS direct IO needs page lock?
Date: Thu, 17 Feb 2005 16:34:51 +0100
Message-ID: <20050217153451.GL23564@suse.de>
References: <20050215203654.GA15634@suse.de> <1108507882.10073.236.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1ngC-0003NU-5e
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 07:35:00 -0800
Received: from mail.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D1ngB-00041z-EH
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 07:35:00 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1108507882.10073.236.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, Feb 15, 2005 at 05:51:22PM -0500, Trond Myklebust wrote:
> ty den 15.02.2005 Klokka 21:36 (+0100) skreiv Olaf Kirch:
> It is intentional. Andrew Morton pointed out that you can play zero-copy
> tricks by doing direct-io on an mmapped range of pages (as seems to be
> the case above).
> 
> That could cause deadlocks if the reader and writer were to both try to
> lock the same page.

Thanks, that helps!

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
