From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Thu, 1 Apr 2004 07:15:34 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BF6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Jeremy McNicoll" <jeremy@mcnicoll.ca>,
        "Patrick Mochel" <mochel@digitalimplant.org>,
        <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B93uz-0006Hw-5i
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 07:15:45 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B93uy-0004ey-P0
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 07:15:44 -0800
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

hi greg-

thanks for the review.

> I don't understand why you have an rpc_tally pointer in rpc_message.
> This just seems to complicate matters by forcing you to initialise
> the pointer to the rpc_tally in the nfs_server on every call.  AFAICT
> all the place where you need the rpc_tally pointer you already have
> an rpc_clnt pointer which is initialised directly from the nfs_server
> and could be made to hold the rpc_tally* instead.  With that reorg
> you could drop most of the 08-rpc_call.patch and all the changes
> to nfs3proc.c and proc.c in nfs-iostat.patch and replace them with
> a small change to nfs_create_client().   That would greatly reduce
> the code perturbation without affecting performance or functionality.

trond wanted a mechanism that could be used for other things besides
per-mount statistics.  for instance, you can allocate a different
tally structure for each inode on a file system, and collect stats
for each of them.  or you can use the same tally struct for files
in the same directory.  nailing the tally structure into the rpc_clnt
makes that kind of usage (which might be nice for debugging) impossible.

there was interest in removing rpc_call() anyway.  this is just a
convenient excuse.

in terms of performance impact, this change is actually pretty
minor compared to the massive amount of data copying done by XDR
and the socket layer, and to the lock contention that occurs in
the RPC client.  as i've inlined nfs3_rpc_wrapper, that more
than makes up for setting a single extra pointer, at least in
the NFSv3 synchronous path.  i don't see that there are any data
dependencies that would cause a pipeline stall when rpc_talp is
set, do you?

> I don't see any way for the userspace program which reads these to
> figure out which of the iostat files corresponds to which mount.
> We get the hostname in the filename and again in the contents but
> nowhere do we get the mount path, only the device minor number in
> the filename.  How about adding a line to nfs_iostat_show() to
> print nfss->mnt_path?

the problem there is namespace.  each process can have its own
set of mount points (ie export to local directory pairings).  we
still need to work out exactly how to provide that information.

i'm not too concerned about that, as iostat on local file systems
currently produces results based on devices, forcing an adminis-
trator to go back to /etc/fstab or df or mount to figure out
what's going on anyway.

> The minor dimension of the 2d array of struct rpc_metrics_totals
> pointed to by rpc_tally is per-CPU.  To get correct per-CPU
> separation you will want to cacheline-align the per-CPU parts
> (so that cachelines which straddle the per-CPU parts don't end
> up bouncing between CPUs).  For example, in rpc_alloc_tally(),
>=20
> size =3D NR_CPUS * ROUNDUP(ops * sizeof(struct=20
> rpc_metric_totals), L1_CACHE_BYTES);
>=20
> and change the stride of the tl_totals[] initialisation loop.

makes sense, will do.

> As others have mentioned, having at least four do_gettimeofday()
> calls per RPC call is evil; we've seen major problems scaling
> do_gettimeofday() on large CPU count Altix machines.  This problem
> also affects some NIC drivers because the network stack does
> a do_gettimeofday() to timestamp every incoming ethernet packet;
> David Miller's proposed solution to that is to define a new
> scalable high-resolution timestamp API.  I don't know if that's
> gone anywhere, you might try asking on the netdev list.

i asked on lkml yesterday.  folks there say "no such API exists."
at this point i'm thinking of using jiffies and calling it a day.
at some later point we can come back and add support for finer
resolution timestamps.  i've already added a timestamp resolution
indicator in the iostat file format, so changing later should be
no problem if user-level pays attention to it.

> So when the mount is unmounted, all stats are lost?  How does this
> work on clients which do intermittent traffic on automount mounts?
> Would it be possible to get some global stats too?

global stats still exist in /proc/net/rpc/  -- anything you
think is missing there?

> The accumulation-over-CPU loops in nfs_iostat_show() and=20
> rpc_print_tally()
> would be simpler if all the fields in struct nfs_iostat and struct
> rpc_metric_totals were a consistent size, so you could just treat the
> structs as an array of that type during the accumulation step.

i'm trying to keep rpc_metric_totals small because there are a whole
lot of them.  i'm not sure i understand exactly what you mean here.
can you give an example?

> In struct nfs_iostat, it would be nice to gather the number of times
> calls retried because they received EJUKEBOX from the server,=20
> the number
> of SETATTRs which cause a truncate, the number of WRITEs which cause
> a file extension, and the number of WRITEs which are not aligned to
> the wsize.

ok, good ideas.

> nfs_iostat_file_name() does an unbounded sprintf() of an=20
> unbounded string
> that comes from userspace (from an unprivileged user if the site runs
> automounter) into a buffer only NFS_PROC_NAMELEN=3D256 bytes long.

good catch.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
