From: Erik Forsberg <forsberg+nfs@cendio.se>
Subject: Mounting HA-NFS-export from both cluster nodes.
Date: 14 Nov 2003 09:34:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <uo7k23l55k.fsf@hostname.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKc25-0000Q9-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 03:22:34 -0800
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AKc25-0002gF-CD
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 03:22:33 -0800
Received: from hostname.lkpg.cendio.se (hostname.lkpg.cendio.se [10.47.3.161])
	by mail.cendio.se (Postfix) with ESMTP id AA926A23C61
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 12:22:31 +0100 (CET)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi!

I'm currently trying to setup a High Availability cluster where:

1) The currently active node export home directories via NFS.
2) Both nodes serve as Linux Terminal Servers where users run
   programs. 

This might seem as a non-orthodox setup, since file servers most often
are dedicated stand-alone machines, but in my context this kind of
setup is wanted anyway because of price/performance factors.

Anyway - the cluster consists of two machines, sharing disk using the
Distributed Replicate Block Device (http://www.drbd.org). This seems
to work quite well, but my problem is that I need to access /home from
both cluster nodes and DRBD (at least in the stable 0.6.x series)
doesn't allow read/write mounts on more than one node at a time, not
to mention the fact that I'd need a cluster file system for that
functionality (most normal filesystems don't enjoy when the underlying
device changes without it's knowledge). 

A short description of my NFS setup might be of interest: The whole
thing is controlled by heartbeat which starts nfs services on the
currently active server (/etc/init.d/nfs start, it's Red Hat Linux 9
systems). rpc.statd is run with the -n <HA hostname> option for locks
to work. In order for locking to work after failover, I share
/var/lib/nfs using DRBD and mount it before starting NFS on the active
node. 

I need to access /home from both nodes regardless of which of the two
nodes that is currently "active" (that is, the node that
read/write-mounts the DRBD device and exports NFS). 

My first thought was to export /export/home via NFS from the currently
active node, and then mount /home via NFS from the HA-interface on
both nodes. Except for some trouble about timing (I need to know that
the HA interface is up and running before I can mount /home), but
that problem was not hard to solve (just run a script after heartbeat
has started that pings the HA interface - mount when an answer comes
back), this seemed to work. I could access /home from both nodes, and
I could do it regardless of which node was active (serving NFS) with
just a minimal stop while doing the failover.

So far so good. Now I tested file locking, and found out that it
didn't work. 

*) On the node currently being active, rpc.statd is as mentioned above
 run with -n <HA hostname>. I'm not sure how this affects the
 client-part of rpc.statd - will the fact that a lock exists be
 properly recorded?

*) On the node currently not exporting NFS, but still mounting /home
 from the active node, /var/lib/nfs doesn't exist with this setup,
 since /var/lib/nfs is shared between the two cluster nodes in order
 for NFS server operations to work as expected.

*) At a failover, /var/lib/nfs of the previously active node will no
 longer be present. Also, the node now active will probably not know
 the previously active node has a lock.

These are just the three problems I've found so far, I wouldn't be
surprised if there are several others. 

Is there a way to solve either my general problem (mounting /home from
a HA-NFS-server on the two cluster nodes), or the problems with the
setup above? As far as I can see, rpc.statd don't have any arguments
that allow it to run several instances, operating as several
hostnames - this would probably help, especially if it could run using
another directory than /var/lib/nfs. On the other hand, there might
very well be problems with the kernel-lockd that prevents correct lock
operations.

Any thoughts on this are welcome.

Regards,
\EF
-- 
Erik Forsberg                Telephone: +46-13-21 46 00
Cendio                       Web: http://www.cendio.se
		             



-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
