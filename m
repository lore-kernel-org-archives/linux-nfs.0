From: jason andrade <jason@dstc.edu.au>
Subject: nfs performance: read only/gigE/nolock/1Tb per day
Date: Sun, 21 Apr 2002 13:27:20 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.OSF.4.20.0204211306180.15511-100000@azure.dstc.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from piglet.dstc.edu.au ([130.102.176.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16z80b-0001Ae-00
	for <nfs@lists.sourceforge.net>; Sat, 20 Apr 2002 20:27:25 -0700
Received: from azure.dstc.edu.au (azure.dstc.edu.au [130.102.176.27])
	by piglet.dstc.edu.au (8.11.3/8.11.3) with ESMTP id g3L3RKr10533
	for <nfs@lists.sourceforge.net>; Sun, 21 Apr 2002 13:27:20 +1000 (EST)
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


Hi,

This is a bit of a long query - i am happy to post a summary back to the
list if i can get sufficient responses.


I've been trying to sort out NFS issues for the last 12 months due to
the increase in traffic we have at our opensource archive (planetmirror.com).

We started with a RedHat 7.0 deployment and the 2.2 kernel series and moved
onto 2.4 to try to address some performance issues.

We are now using a Redhat 7.2 deployment and have recently upgraded to the
2.4.18-0.22 kernel tree in an effort to deal with NFS lock ups and performance
issues. 

At peak we are pushing between 700-1000Gigabytes of traffic daily.  I am not
sure if that's at the upper boundries of what NFS testing is done at or not.

I don't believe there are any back end bandwidth issues from the disk - there
are two QLA2200 HBAs each with 2 LUNs coming from a separate fibrechannel
RAID server (PV650F) with 10 disks in each lun (36G 10,000RPM fibrechannel)

Testing has shown the ability to exceed > 50Mbyte/sec from the disk subsystem.


Some questions/queries:

o we have upgraded our backbone so that the server and all clients have gigE
  cards (previously the server had gigE and the clients had 100Bt) into a
  unmanaged switch on a private NFS backbone (i.e separate physical interface
  for nfs exports/client mounts from the "outbound" application interface)

  is there any benefit in jumbo packets and setting the MTU to 9000 ?

o we have periodic lockups - these were pretty bad with 2.4.9 or older with
  a lockup almost twice a day.  restarting the NFS subsystem made no difference
  and only a reboot of the server would clear it.

  we have been able to reproduce this with the 2.4.9-31 kernel though it is much
  rarer (once every 2-3 days).

  in an effort to avoid this, we've upgraded to 2.4.18-0.22 redhat rawhide kernel
  and i will monitor it over the next few days to see how it goes.

o we are using read only nfs - are there any optimizations or other tweaks that can
  be done knowing our front end boxes only mount filesystems as read only ?

  i have already turned off NFS locking on the server and client.


o is it possible to change NFS mount size from 1024 to 8192 (especially with GigE).
  i have tried this and was seeing slowdowns in nfs access, so reverted back to
  1024 block size.

o is there any benefit of nfs over TCP rather than UDP, when using a local gigE
  switch between server and clients ?  and any benefit in increased block size
  16K or 32K? if using tcp ?


o is there an easy way to work out what if any patches by Trond or Neil Brown are
  applied to redhat kernels ?  i'm having a hard time figuring out if i should be
  applying NFS_ALL patches to redhat rawhide trees.  and in particular, Neil has
  a patch that should make a significant performance improvement to SMP NFS servers
  which i'd like to see.  trying to track stuff through bugzilla, the varioous changelogs
  and manually is proving difficult.


o current config/performance.

  currently, top shows me that "system" uses about 70% of resources on both cpus,
  with the system around 30% idle.  i have 256 nfsds running on the server.  exports
  are ro with no_subtree_check.

  on the client, about 50-60% of cpu is spent in system, with average load around
  10-25.  at times it will spike to 100-200.  the front end box is attempting to
  service > 1000 apache clients and > 250 ftp clients.


  the NFS server filesystems are mounted ext3 with: 
  rw,async,auto,noexec,nosuid,nouser,noatime,nodev

  the NFS clients mount the filesystems with: 
  ro,rsize=1024,nolock,hard,bg,intr,retrans=8,nfsvers=3,timeo=10

  

cheers,

-jason


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
