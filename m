From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: 17 Jul 2006 15:17:12 -0300
Message-ID: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2Xh0-0000dg-V9
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 11:19:43 -0700
Received: from [200.9.237.134] (helo=intec.unl.edu.ar)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G2Xgx-0002Ow-KU
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 11:19:43 -0700
Received: from minerva.ceride.gov.ar.ceride.gov.ar (localhost [127.0.0.1])
	by intec.unl.edu.ar (8.12.8/8.12.8) with ESMTP id k6HIre8o008105
	for <nfs@lists.sourceforge.net>; Mon, 17 Jul 2006 15:53:41 -0300
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi all, 

We have still problems with NFS in our Beowulf cluster. The original
post is here

http://thread.gmane.org/gmane.linux.nfs/9564/focus=9566

The news are that we reproduced the problem on Scientific Linux 4.2
and also without VNFS. In addition we have taken a tethereal capture
that may help in understanding the problem. 

In brief we have a Beowulf class cluster built on Scientific Linux
(Beryllium) 4.2, (kernel 2.6.9-22.0.1). The cluster is disk-less
(nodes don't have hard disks) based on the Warewulf package. NFS
traffic is reduced by using VNFS filesystems at the nodes. However we
reproduced the problem in a configuration with disks at the nodes. 

The problem is that for some files in user accounts if we make some
modifications to the file in the server, this changes are not seen in
the compute nodes. The NFS server is NFS3 and with the standard
configuration (8 instances of the server and default parameters). The
cluster has 20 nodes at this time, but we have made experiments with a
`cloned' cluster and even with only two nodes the problem persist.

The experiment is as follows: We change a text file in a user account
with Emacs and checking whether the change is seen in the compute
nodes. Sometimes the change is immediately seen in the compute nodes,
but many times some nodes don't see the change. 

This happens even when the cluster is idle (no computing or network
load in the slave nodes, neither on the server), so it's not a problem
of performance. It is plainly working bad.

`rpcinfo -p' and `nfsstat' on the server and on the client can be
found in the riginal post.

We tried several combinations for the export and mount options
(sync/async...) with no success. 

We made en experiment and you can find the tethereal log here

http://venus.ceride.gov.ar/~mstorti/tempo/tethereal-raw10.log.gz

The process is as follows: we start with a file `foo5' and we verify
that two compute nodes (node1 and node11) see the same file. After
that we modify the file in the server and look what the compute nodes
see. I verify that node1 sees (correctly) the change, while `node11'
doesn't see the change.

These are the operations 

* Modify file foo5 in server, adding a line with 'jaja27'
* grep jaja in node1 -> reports `jaja27'   (OK)
* grep jaja in node11 -> reports `jaja27'   (OK)
* Modify file foo5 in server, replace 'jaja27' by 'jaja28'
* grep jaja in node1 -> reports `jaja28'   (OK)
* grep jaja in node11 -> reports `jaja27'   (NOT OK)


These are the shell commands:
================================================================
                            [[turn on tethereal]]
                            [[Emacs writes #jaja27 to foo5 on server]]
[mstorti@aquiles ~]$ rsh node1 grep jaja foo5
# jaja27
[mstorti@aquiles ~]$ rsh node11 grep jaja foo5
# jaja27
                            [[Emacs changes 27 to 28 in foo5 on server]]
[mstorti@aquiles ~]$ rsh node1 grep jaja foo5
# jaja28
[mstorti@aquiles ~]$ rsh node11 grep jaja foo5
# jaja27
[mstorti@aquiles ~]$
                            [[turn off tethereal]]
================================================================

I examined the frames in the tethereal log and I found the following. 

first rsh from node1: frame 183: GETATTR reply mtime:
21:36:21.975422000

first rsh from node11: frame 378: GETATTR reply mtime:
21:36:21.975422000

second rsh from node1: frame 564: GETATTR reply mtime:
21:37:37.515422000
                       frame 566: READ

second rsh from node11: frame 713: LOOKUP reply mtime:
21:37:37.515422000

Note: the inode for the file /u/mstorti/foo  is 11590453. 

So, during the second rsh from both nodes the clients receives an
mtime for the file that is posterior to the one during the first
read. The client at node1 correctly requires the new file contents
with a READ, while the client from node11 doesn't. I assume that the
client uses the contents in the cache (which is wrong). 

Sorry for the way long post. Any help is appreciated,

TIA, Mario



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
