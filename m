From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Thu, 01 Apr 2004 18:13:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406BCF31.B274D7E5@melbourne.sgi.com>
References: <482A3FA0050D21419C269D13989C61130435DE31@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy McNicoll <jeremy@mcnicoll.ca>,
        Patrick Mochel <mochel@digitalimplant.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8xL3-0004Zc-5x
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 00:14:13 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8xL2-0003YZ-Rh
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 00:14:12 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

G'day,

[cc trimmed somewhat]

"Lever, Charles" wrote:
> 
>   -------------------------------------------------------------------------------------
>                               Name: 06-rpc_metrics.patch
>    06-rpc_metrics.patch       Type: unspecified type (application/octet-stream)
>                           Encoding: base64
>                        Description: 06-rpc_metrics.patch
>   -------------------------------------------------------------------------------------
>                              Name: 07-nfs-iostat.patch
>    07-nfs-iostat.patch       Type: unspecified type (application/octet-stream)
>                          Encoding: base64
>                       Description: 07-nfs-iostat.patch
>   -------------------------------------------------------------------------------------
>                            Name: 08-rpc_call.patch
>    08-rpc_call.patch       Type: unspecified type (application/octet-stream)
>                        Encoding: base64
>                     Description: 08-rpc_call.patch


These patches look great, I'm very happy to see extended stats
on the client and I expect it will be very useful debugging
performance and other problems.  Thanks!  Just a few comments...


I don't understand why you have an rpc_tally pointer in rpc_message.
This just seems to complicate matters by forcing you to initialise
the pointer to the rpc_tally in the nfs_server on every call.  AFAICT
all the place where you need the rpc_tally pointer you already have
an rpc_clnt pointer which is initialised directly from the nfs_server
and could be made to hold the rpc_tally* instead.  With that reorg
you could drop most of the 08-rpc_call.patch and all the changes
to nfs3proc.c and proc.c in nfs-iostat.patch and replace them with
a small change to nfs_create_client().   That would greatly reduce
the code perturbation without affecting performance or functionality.


I don't see any way for the userspace program which reads these to
figure out which of the iostat files corresponds to which mount.
We get the hostname in the filename and again in the contents but
nowhere do we get the mount path, only the device minor number in
the filename.  How about adding a line to nfs_iostat_show() to
print nfss->mnt_path?


The minor dimension of the 2d array of struct rpc_metrics_totals
pointed to by rpc_tally is per-CPU.  To get correct per-CPU
separation you will want to cacheline-align the per-CPU parts
(so that cachelines which straddle the per-CPU parts don't end
up bouncing between CPUs).  For example, in rpc_alloc_tally(),

size = NR_CPUS * ROUNDUP(ops * sizeof(struct rpc_metric_totals), L1_CACHE_BYTES);

and change the stride of the tl_totals[] initialisation loop.


As others have mentioned, having at least four do_gettimeofday()
calls per RPC call is evil; we've seen major problems scaling
do_gettimeofday() on large CPU count Altix machines.  This problem
also affects some NIC drivers because the network stack does
a do_gettimeofday() to timestamp every incoming ethernet packet;
David Miller's proposed solution to that is to define a new
scalable high-resolution timestamp API.  I don't know if that's
gone anywhere, you might try asking on the netdev list.


So when the mount is unmounted, all stats are lost?  How does this
work on clients which do intermittent traffic on automount mounts?
Would it be possible to get some global stats too?


The accumulation-over-CPU loops in nfs_iostat_show() and rpc_print_tally()
would be simpler if all the fields in struct nfs_iostat and struct
rpc_metric_totals were a consistent size, so you could just treat the
structs as an array of that type during the accumulation step.


In struct nfs_iostat, it would be nice to gather the number of times
calls retried because they received EJUKEBOX from the server, the number
of SETATTRs which cause a truncate, the number of WRITEs which cause
a file extension, and the number of WRITEs which are not aligned to
the wsize.


nfs_iostat_file_name() does an unbounded sprintf() of an unbounded string
that comes from userspace (from an unprivileged user if the site runs
automounter) into a buffer only NFS_PROC_NAMELEN=256 bytes long.


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
