From: Juan Gomez <juang@us.ibm.com>
Subject: Proposal for new lock ownership scheme to support NFS over distributed
 filesystems
Date: Thu, 31 Oct 2002 10:05:51 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF322A6213.F82904FF-ON87256C63.00620AD8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e5.ny.us.ibm.com ([32.97.182.105])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Jhf-0008Uu-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 10:05:59 -0800
To: linux-kernel@vger.kernel.org
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





Hello all,

As a prelude to adding support in kNFS(lockd) to pass lock information via
the VFS interface I want to firsr propose some minor changes that will
enable us to have a single lock ownership space that is shared and enforced
at all nodes.

Currently lockd identified range locks with two fields fl_owner and fl_pid.
NFS code places a memory pointer (pointer to host structure representing
NFS client holding the lock) in fl_owner which works great in single node
NFS but breaks when we attempt to pass lock requests to an the underlying
distributed filesystem in the context of a clustered NAS head. This can be
easily fixed by filling fl_owner field with the IP address of the NFS
client requesting the lock, which is just a minor patch.

The patch above, however, does not fix all our problems as locks acquired
locally in the NFS server nodes could collide with NFS locks. Currently,
the fl_owner field for locks acquired via the local file system is filled
with another memory pointer (i.e. current->files). This also breaks appart
when using a distributed file system. My proposal for this would be use a
local IP address to put in the fl_owner field of locks acquired locally in
a node.

These two patches cause no problem for current single node NFS servers and
enable Linux as a platform to support distributed filesystems and NFS
serving simultaneously and correctly.

I would like to get your feedback on this proposal and if accepted as it is
I will later follow with patches for current versions of the kernel NFS.


Regards, Juan



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
