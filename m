From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Fri, 25 Feb 2005 10:28:09 +0100
Message-ID: <20050225092809.GD15249@suse.de>
References: <20050223162808.GB17774@suse.de> <1109176559.10142.4.camel@lade.trondhjem.org> <Pine.LNX.4.58.0502241055521.2188@wombat.indigo.net.au> <1109218999.11180.49.camel@lade.trondhjem.org> <20050224101449.GB11336@suse.de> <1109268742.11433.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4bm0-0002EA-Qx
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 01:28:36 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D4blh-0005SH-0A
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 01:28:36 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109268742.11433.14.camel@lade.trondhjem.org>
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

On Thu, Feb 24, 2005 at 10:12:22AM -0800, Trond Myklebust wrote:
> It is needed in the kernel if you want to use connection pools in order
> to make disconnection and port re-use fast. Fast port re-use is also
> needed in order to deal with idempotency issues when the TCP connection
> fails (the server replay cache is usually indexed on the port number).

Is the whole nfsd cache still that important for TCP connections?
It's mostly useless with multi-homing, it will become even more so if we
ever do load balancing across multiple TCP connections...  Indexing
by network protocol information is broken beyond fixing, and the only
way to salvage the cache for TCP is to start indexing it differently
(eg based on a hash of parts of the RPC header and creds)

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
