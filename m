From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: NFS synchronization problems on Beowulf cluster
Date: Wed, 31 May 2006 19:23:13 +0000 (UTC)
Message-ID: <loom.20060531T205740-641@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlnB6-0005oz-EN
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 06:25:32 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlnB4-0007Ex-Be
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 06:25:31 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FlnAv-0003qd-Qw
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 06:25:27 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1FlnAd-00024X-38
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:25:03 +0200
Received: from rev2009237.secyt.gov.ar ([rev2009237.secyt.gov.ar])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 15:25:03 +0200
Received: from mstorti by rev2009237.secyt.gov.ar with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 15:25:03 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi all, 

We have a Beowulf class cluster built on Linux Fedora Core 3 (kernel
2.6.15). The cluster is disk-less (nodes don't have hard disks) based
on the Warewulf package. NFS traffic is reduced by using VNFS
filesystems at the nodes.

We found something strange related with NFS. For some files in user
accounts if we make some modifications to the file in the server, this
changes are not seen in the compute nodes. The NFS server is NFS3 and
with the standard configuration (8 instances of the server and default
parameters). The cluster has 20 nodes at this time, but we have made
experiments with a `cloned' cluster and even with only two nodes the
problem persist. 

The experiment is as follows: We change a text file in a user account
with Emacs and checking whether the change is seen in the compute
nodes. Sometimes the change is immediately seen in the compute nodes,
but many times some nodes don't see the change. 

This happens even when the cluster is idle (no computing or network
load in the slave nodes, neither on the server), so it's not a problem
of performance. It is plainly working bad.

Below are the `rpcinfo -p' and `nfsstat' on the server and on the
client. The version of nfs-utils are 1.0.6. 

We tried several combinations for the export and mount options
(sync/async...) with no success. 

Any help is appreciated,

TIA, Mario

http://www.cimec.org.ar/mstorti

======================= SERVER =================================
[root@aquiles ~]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    947  status
    100024    1   tcp    950  status
    100011    1   udp    777  rquotad
    100011    2   udp    777  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100021    1   tcp  32769  nlockmgr
    100021    3   tcp  32769  nlockmgr
    100021    4   tcp  32769  nlockmgr
    100005    1   udp    795  mountd
    100005    1   tcp    798  mountd
    100005    3   udp    795  mountd
    100005    3   tcp    798  mountd
[root@aquiles ~]# nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
3734126    0          0          0          0       
Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
240     0% 1375308 36% 86317   2% 135591  3% 605405 16% 1719    0% 
read       write      create     mkdir      symlink    mknod      
72626   1% 1352149 36% 9697    0% 0       0% 0       0% 160     0% 
remove     rmdir      rename     link       readdir    readdirplus
4909    0% 0       0% 64      0% 30      0% 18      0% 60812   1% 
fsstat     fsinfo     pathconf   commit     
0       0% 122     0% 0       0% 28958   0% 

======================= COMPUTE NODE =============================

[root@node1 ~]# rpcinfo -p
   programa vers proto   puerto
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    892  status
    100024    1   tcp    895  status
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100021    1   tcp  53111  nlockmgr
    100021    3   tcp  53111  nlockmgr
    100021    4   tcp  53111  nlockmgr
[root@node1 ~]# nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
0          0          0          0          0       
Client rpc stats:
calls      retrans    authrefrsh
2950634    0          0       
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 988154 33% 86986   2% 44612   1% 353215 11% 102     0% 
read       write      create     mkdir      symlink    mknod      
6821    0% 1367868 46% 9227    0% 0       0% 0       0% 8       0% 
remove     rmdir      rename     link       readdir    readdirplus
4577    0% 0       0% 7       0% 18      0% 18      0% 59879   2% 
fsstat     fsinfo     pathconf   commit     
0       0% 2       0% 0       0% 29138   0% 





-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
