From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Thu, 01 Apr 2004 19:34:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080866042.10521.11.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C611302B07BF6@lavender-fe.eng.netapp.com>
	 <20040401235803.GA9409@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Charles Lever <Charles.Lever@netapp.com>, Jeremy McNicoll <jeremy@mcnicoll.ca>, Patrick Mochel <mochel@digitalimplant.org>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CdU-000400-QL
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:34:16 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B9CdR-000519-Jp
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:34:13 -0800
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040401235803.GA9409@sgi.com>
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

On Thu, 2004-04-01 at 18:58, Greg Banks wrote:

> struct rpc_metric_totals {
> 	u64 mt_ops;         /* count of operations */
> 	u64 mt_ntrans;      /* count of RPC transmissions */
> 	u64 mt_cwnd;        /* congestion window util */
> 	u64 mt_cong;        /* congestion window util */
> 	u64 mt_slot_u;      /* slot table utilization */
> 	u64 mt_sndq_u;      /* send queue utilization */
> 	u64 mt_bklog_u;     /* backlog utilization */
> 	u64 mt_errors;      /* count of EIO errors */
> 
> 	u64 mt_bytes_sent;  /* count of bytes out */
> 	u64 mt_bytes_recv;  /* count of bytes in */
> 	u64 mt_sendbuf;     /* total sendbuf */
> 
> 	u64 mt_rtt;         /* usecs for RPC RTT */
> 	u64 mt_rtt_s;       /* sum(rtt**2) */
> 	u64 mt_execute;     /* usecs for RPC execution */
> 	u64 mt_execute_s;   /* sum(execute**2) */
> };
> 
> rpc_print_tally(...)
> {
> ...
> 	for (op = 0; op < vers->nrprocs; op++) {
> 		memset(&total, 0, sizeof(struct rpc_metric_totals));
> 		for (i = 0; i < NR_CPUS; i++) {
> 			u64 *r = tally->tl_totals[i];
> 			for (k = 0 ; k < sizeof(struct rpc_metric_totals)/sizeof(u64) ; k++)
> 				((u64 *)&total)[k] += r[k];
> 		}
> 	}
> }

Let's not go there... 64-bit arithmetic on a 32-bit platform is still
not one of gcc's strong points, so let's not force everything into one
mold simply in order to save a couple of lines of code. Performance does
matter too...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
