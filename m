From: James Bottomley <James.Bottomley@steeleye.com>
Subject: High Availability NFS Proposal
Date: Sat, 24 Aug 2002 18:16:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208242216.g7OMG3802286@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James.Bottomley@SteelEye.com, lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host194.steeleye.com ([216.33.1.194] helo=pogo.mtv1.steeleye.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ijCd-0006Jp-00
	for <nfs@lists.sourceforge.net>; Sat, 24 Aug 2002 15:16:19 -0700
Received: (from root@localhost)
	by pogo.mtv1.steeleye.com (8.9.3/8.9.3) id PAA12902
	for <nfs@lists.sourceforge.net>; Sat, 24 Aug 2002 15:16:18 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi All,

My company, SteelEye Technology, already has a HA-NFS offering (using 
filehandle aliasing and kernel authentication add ons).  However, We'd like to 
enhance the existing open source solution (actually, our current patches are 
open source, I just got tired of merging them to each revision of whatever 
distributions kernel).  The new fsid option already performs the same task as 
our kernel filehandle aliasing patches, so the only remaining issues are 
authentication and locking.

Unfortunately, our product, LifeKeeper, is more complex than just a simple two 
node active passive cluster, so the usual just share /var/lib/nfs solution 
won't work for us.  What I'd like to propose instead is to place hooks inside 
mountd and statd that would allow them to propagate the necessary state 
information into a cluster.  The best way I can think of is to designate two 
executable hooks (say /var/lib/nfs/mountd-hook and /var/lib/nfs/statd-hook).  
If mountd and statd don't find these on start up, they proceed normally.  
However, if they exist, mountd and statd will execute them with certain 
arguments to allow the clustering software to keep track of the client 
machines correctly.

These modifications should be enough to allow HA-NFS.  However, to preserve 
locks on failover, I need to introduce statd to the concept of virtual hosts, 
so it can be told to stop tracking a virtual host, or behave as though a 
virtual host had crashed.  There are already the beginnings of IP aliasing 
support in statd.c, so it shouldn't be too hard to progress to the full blown 
solution.

I'll proceed in two phases: mountd first to give a HA solution and statd next 
to give the complete HA-NFS solution.  The hooks should be useable by any HA 
clustering software on Linux.

Any feedback anyone might have on this proposal would be more than welcome.

James Bottomley




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
