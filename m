From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 25 Feb 2004 20:10:19 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040226041019.86427.qmail@web12823.mail.yahoo.com>
References: <403D692D.33C4D7E8@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwCsa-0002CS-DV
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 20:12:08 -0800
Received: from web12823.mail.yahoo.com ([216.136.174.204])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AwCdV-0007yE-JW
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 19:56:33 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <403D692D.33C4D7E8@melbourne.sgi.com>
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

While the solution you propose certainly sounds more
elegant, in my experience, asynchronous writes seem to
eat up most of the RPC slots in normal use and this
patch only modifies the write path without affecting
the core RPC scheduler.  Surely, a solution that fixes
the common case should be acceptable until the more
elegant one is available?  The NFS client in Linux has
suffered from this issue for quite a while and I don't
recall seeing a patch that addressed this issue.  If
there is something available to test, I'd certainly
like to look at it.  As such, the current NFS client
is basically useless for concurrent activity in the
presence of heavy writers.

Shantanu

--- Greg Banks <gnb@melbourne.sgi.com> wrote:
> Shantanu Goel wrote:
> > 
> > The stock NFS client does not regulate the # async
> > write requests causing other accesses to block in
> the
> > presence of streaming writes.  
> 
> This is a real problem; the same problem in IRIX was
> fixed at
> 6.5.17 (about 2 years ago).
> 
> > This patch adds such
> > support.  For instance, a single dd running in the
> > background writing to a file in my home directory
> > causes my X session to hang until dd exits.  With
> this
> > patch the session does not experience such hangs.
> > Please test it out and let me know if you see
> anything
> > problems.  I'd like to see this integrated soon.
> 
> I discussed this with Dave Chinner (who implemented
> IRIX' write
> throttling), and our conclusion was that this is
> implementing
> throttling at the wrong level.  A better approach
> would be to
> change the allocation algorithm of rpc_rqsts to
> divide the
> RPC_MAXREQS space into three fixed spaces by class:
> sync calls,
> async (writes & commits), and all other async calls.
>  Attempts to
> allocate a request slot can then be classified into
> one of
> these classes in the struct rpc_procinfo, and when a
> class'
> space is full the allocation fails; the rpc_task
> already knows
> how to sleep and retry request slot allocation.
> 
> Alternately, the allocation could treat the classes
> as priority
> classes with sync calls given the highest priority;
> allocations
> would succeed only if there were slots available at
> the same or
> less important priority.  For example, there were
> patches to do
> similar things to the block device layer.
> 
> The exact numbers chosen for the class sizes will be
> a subtle
> and important tuning decision.  It will probably pay
> to bump up
> RPC_MAXREQS to compensate for the subdivision;
> you'll want the
> class for async writes to still be 16 slots in size.
> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian
> Software Group.
> I don't speak for SGI.


__________________________________
Do you Yahoo!?
Get better spam protection with Yahoo! Mail.
http://antispam.yahoo.com/tools


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
