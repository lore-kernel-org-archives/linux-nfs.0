From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Thu, 1 Apr 2004 08:45:40 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DE4B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B95KB-00040J-34
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 08:45:51 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B95KA-0004b1-Qj
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 08:45:50 -0800
To: "Greg Banks" <gnb@melbourne.sgi.com>
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

> The minor dimension of the 2d array of struct=20
> rpc_metrics_totals pointed to by rpc_tally is per-CPU.  To=20
> get correct per-CPU separation you will want to=20
> cacheline-align the per-CPU parts (so that cachelines which=20
> straddle the per-CPU parts don't end up bouncing between=20
> CPUs).  For example, in rpc_alloc_tally(),
>=20
> size =3D NR_CPUS * ROUNDUP(ops * sizeof(struct=20
> rpc_metric_totals), L1_CACHE_BYTES);
>=20
> and change the stride of the tl_totals[] initialisation loop.

that doesn't work, unfortunately, unless sizeof(struct rpc_tally)
is also an exact multiple of L1_CACHE_BYTES.  otherwise the whole
metrics array starts on a non-cache-aligned boundary since these
are all cut from the same piece of memory.

what is the preferred mechanism these days for ensuring that
structures like these are sized in multiples of L1_CACHE_BYTES?
if i can get the C compiler to do this, that would be a cleaner
solution.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
