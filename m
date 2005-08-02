From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] sunrpc: cache_register can use wrong module reference
Date: Tue, 2 Aug 2005 22:51:00 +0100
Message-ID: <20050802215100.GA19079@infradead.org>
References: <1123018176.3954.118.camel@w-bwa3.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	linux-nfs <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E04fL-0005ih-W4
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 14:51:15 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E04fK-0001Bu-R9
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 14:51:16 -0700
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: <1123018176.3954.118.camel@w-bwa3.beaverton.ibm.com>
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

On Tue, Aug 02, 2005 at 02:29:36PM -0700, Bruce Allan wrote:
> [resending to Neil, Trond and linux-nfs list; initial copy to lkml]
> 
> When registering an RPC cache, cache_register() always sets the owner as
> the sunrpc module.  However, there are RPC caches owned by other modules. 
> With the incorrect owner setting, the real owning module can be removed
> potentially with an open reference to the cache from userspace.
> 
> For example, if one were to stop the nfs server and unmount the nfsd
> filesystem, the nfsd module could be removed eventhough rpc.idmapd had
> references to the idtoname and nametoid caches (i.e.
> /proc/net/rpc/nfs4.<cachename>/channel is still open).  This resulted in
> a system panic on one of our machines when attempting to restart the nfs
> services after reloading the nfsd module.
> 
> The following patch fixes this by passing the address of the owning
> struct module to cache_register().  In addition, printk's were added to
> functions calling cache_unregister() to dump an error message on
> failure.
> 
> Signed-off-by: Bruce Allan <bwa@us.ibm.com>

Please put a

	struct module	*owner;

field into struct cache_detail instead, that's how it works for other
methods tables like that.

And while we're at it, cache_detail is an awfully generic name for a sunrpc
data structure.



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
