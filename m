From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 2 Apr 2004 09:58:03 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040401235803.GA9409@sgi.com>
References: <482A3FA0050D21419C269D13989C611302B07BF6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy McNicoll <jeremy@mcnicoll.ca>,
        Patrick Mochel <mochel@digitalimplant.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9C4x-0006N0-Gs
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 15:58:35 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9C4x-000310-5g
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 15:58:35 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07BF6@lavender-fe.eng.netapp.com>
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

On Thu, Apr 01, 2004 at 07:15:34AM -0800, Lever, Charles wrote:
>
> trond wanted a mechanism that could be used for other things besides
> per-mount statistics.  for instance, you can allocate a different
> tally structure for each inode on a file system, and collect stats
> for each of them.  or you can use the same tally struct for files
> in the same directory.  nailing the tally structure into the rpc_clnt
> makes that kind of usage (which might be nice for debugging) impossible.

Ah.  I didn't realise that was a requirement.

> there was interest in removing rpc_call() anyway.  

Why?

> in terms of performance impact, this change is actually pretty
> minor

Agreed, I saw no performance issues other than do_gettimeofday().

> > I don't see any way for the userspace program which reads these to
> > figure out which of the iostat files corresponds to which mount.
> 
> the problem there is namespace.  each process can have its own
> set of mount points (ie export to local directory pairings).  we
> still need to work out exactly how to provide that information.

Actually I was interested in knowing the serverside mount path,
which doesn't depend on the client's namespace (although it's not
necessarily unique).

The obvious solution to the namespace issue is to just use the
namespace of the process doing the /proc read, which should be
current->namespace during nfs_iostat_show().  For almost every
case this will be the default namespace anyway.  In the unlikely
case the the sb is not mounted in that namespace, return early
and don't print any stats.

> i'm not too concerned about that, as iostat on local file systems
> currently produces results based on devices, forcing an adminis-
> trator to go back to /etc/fstab or df or mount to figure out
> what's going on anyway.

This works because for local filesystems those sources give you
the device name.  However (at least on my system) neither fstab
nor mount nor /proc/mounts will tell you anything about the device
number for NFS filesystems.

So what I see from "mount" is

server:/ on /mnt/foo type nfs (rw,addr=134.14.54.149)

and in /proc/mounts

server:/ /mnt/foo nfs rw,v3,rsize=32768,wsize=32768,hard,udp,lock,addr=server 0 0

So how am I supposed to correlate this back to a device minor?

> > As others have mentioned, having at least four do_gettimeofday()
> > calls per RPC call is evil; 
> 
> i asked on lkml yesterday.  folks there say "no such API exists."
> at this point i'm thinking of using jiffies and calling it a day.

Fair enough.

> > So when the mount is unmounted, all stats are lost?  How does this
> > work on clients which do intermittent traffic on automount mounts?
> > Would it be possible to get some global stats too?
> 
> global stats still exist in /proc/net/rpc/  -- anything you
> think is missing there?

It would be nice to have all the same stats as are gathered per-mount,
in the same format so we only have to write and debug one userspace
parsing routine.  In particular, the latency stats.

> > The accumulation-over-CPU loops in nfs_iostat_show() and 
> > rpc_print_tally()
> > would be simpler if all the fields in struct nfs_iostat and struct
> > rpc_metric_totals were a consistent size, so you could just treat the
> > structs as an array of that type during the accumulation step.
> 
> i'm trying to keep rpc_metric_totals small because there are a whole
> lot of them. 

Sure, highly admirable.

> i'm not sure i understand exactly what you mean here.
> can you give an example?

struct rpc_metric_totals {
	u64 mt_ops;         /* count of operations */
	u64 mt_ntrans;      /* count of RPC transmissions */
	u64 mt_cwnd;        /* congestion window util */
	u64 mt_cong;        /* congestion window util */
	u64 mt_slot_u;      /* slot table utilization */
	u64 mt_sndq_u;      /* send queue utilization */
	u64 mt_bklog_u;     /* backlog utilization */
	u64 mt_errors;      /* count of EIO errors */

	u64 mt_bytes_sent;  /* count of bytes out */
	u64 mt_bytes_recv;  /* count of bytes in */
	u64 mt_sendbuf;     /* total sendbuf */

	u64 mt_rtt;         /* usecs for RPC RTT */
	u64 mt_rtt_s;       /* sum(rtt**2) */
	u64 mt_execute;     /* usecs for RPC execution */
	u64 mt_execute_s;   /* sum(execute**2) */
};

rpc_print_tally(...)
{
...
	for (op = 0; op < vers->nrprocs; op++) {
		memset(&total, 0, sizeof(struct rpc_metric_totals));
		for (i = 0; i < NR_CPUS; i++) {
			u64 *r = tally->tl_totals[i];
			for (k = 0 ; k < sizeof(struct rpc_metric_totals)/sizeof(u64) ; k++)
				((u64 *)&total)[k] += r[k];
		}
	}
}

The idea being that adding another field to rpc_metric_totals
becomes easier.  Obviously the cost is higher memory use.
Just an idea.

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
