From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 2 Apr 2004 10:10:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040402001047.GC9409@sgi.com>
References: <482A3FA0050D21419C269D13989C61130435DE4B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CH8-0000HT-He
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:11:10 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CH8-0000Dn-9A
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:11:10 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DE4B@lavender-fe.eng.netapp.com>
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

On Thu, Apr 01, 2004 at 08:45:40AM -0800, Lever, Charles wrote:
> > The minor dimension of the 2d array of struct 
> > rpc_metrics_totals pointed to by rpc_tally is per-CPU.  To 
> > get correct per-CPU separation you will want to 
> > cacheline-align the per-CPU parts (so that cachelines which 
> > straddle the per-CPU parts don't end up bouncing between 
> > CPUs).  For example, in rpc_alloc_tally(),
> > 
> > size = NR_CPUS * ROUNDUP(ops * sizeof(struct 
> > rpc_metric_totals), L1_CACHE_BYTES);
> > 
> > and change the stride of the tl_totals[] initialisation loop.
> 
> that doesn't work, unfortunately, unless sizeof(struct rpc_tally)
> is also an exact multiple of L1_CACHE_BYTES.  otherwise the whole
> metrics array starts on a non-cache-aligned boundary since these
> are all cut from the same piece of memory.

That's right, you'll need to add ____cacheline_aligned like this:

struct rpc_tally {
} ____cacheline_aligned;

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
