From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 14:34:05 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403D692D.33C4D7E8@melbourne.sgi.com>
References: <20040225022210.51884.qmail@web12821.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwCJb-0002h8-4T
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 19:35:59 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwC4Y-000492-FJ
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 19:20:26 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
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

Shantanu Goel wrote:
> 
> The stock NFS client does not regulate the # async
> write requests causing other accesses to block in the
> presence of streaming writes.  

This is a real problem; the same problem in IRIX was fixed at
6.5.17 (about 2 years ago).

> This patch adds such
> support.  For instance, a single dd running in the
> background writing to a file in my home directory
> causes my X session to hang until dd exits.  With this
> patch the session does not experience such hangs.
> Please test it out and let me know if you see anything
> problems.  I'd like to see this integrated soon.

I discussed this with Dave Chinner (who implemented IRIX' write
throttling), and our conclusion was that this is implementing
throttling at the wrong level.  A better approach would be to
change the allocation algorithm of rpc_rqsts to divide the
RPC_MAXREQS space into three fixed spaces by class: sync calls,
async (writes & commits), and all other async calls.  Attempts to
allocate a request slot can then be classified into one of
these classes in the struct rpc_procinfo, and when a class'
space is full the allocation fails; the rpc_task already knows
how to sleep and retry request slot allocation.

Alternately, the allocation could treat the classes as priority
classes with sync calls given the highest priority; allocations
would succeed only if there were slots available at the same or
less important priority.  For example, there were patches to do
similar things to the block device layer.

The exact numbers chosen for the class sizes will be a subtle
and important tuning decision.  It will probably pay to bump up
RPC_MAXREQS to compensate for the subdivision; you'll want the
class for async writes to still be 16 slots in size.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
