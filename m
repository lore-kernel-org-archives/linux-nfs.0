From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Mon, 9 Feb 2004 11:28:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209102801.GC21364@suse.de>
References: <20040207144405.GA19416@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aq8ey-0006Kb-8s
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 02:29:00 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Aq8ex-0007y8-RK
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 02:29:00 -0800
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040207144405.GA19416@lst.de>
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

On Sat, Feb 07, 2004 at 03:44:05PM +0100, Christoph Hellwig wrote:
> The rpciod shutdown code gives ugly sleep_on without BKL warnings in
> -mm.  And it looks indeed somewhat racy.

Yes, this code is indeed one of the areas that breaks when you use
the sunrpc code without the BKL. Another one was the missing spinlock
in xprt_alloc_xid. The code in fs/nfs/unlink.c is probably also racy
without BKL.

So if you remove the sunrpc BKL be prepared for lots and lots
of bug reports :)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
