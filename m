From: Bernd Schubert <bernd-schubert@web.de>
Subject: knfsd & unfsd on the same server
Date: Thu, 27 Feb 2003 17:45:20 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302271745.20691.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: clusternfs-users@lists.sourceforge.net
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

Hi,

I would like to get knfsd and unfsd (actually ClusterNFS) running on the same 
server. Actually this already working, even without modifying the source 
code, when e.g. unfsd is running on another port. 
However, on stopping any of both servers, both are unregistered from rpc, as 
rpcinfo shows. Furthermore there are strange log-file messages on mounting 
from unfsd, probably since first the wrong rpc.mountd is being called.

To improve this I tried to change the rpc-program numbers in unfsd. For the  
rpc.mountd from unfsd this works fine, however when I *also* change the 
rpc-number for the nfsd (unfsd), I can't mount from this server. 
Here are 2 example commands:

mount -t nfs localhost:/test1	/mnt/test1 #would mount from knfsd

mount -t nfs -o mountprog=110005,nfsprog=110003,port=2050 localhost:/test1 
/mnt/test2


So again, when I only change the mountd-rpc-program-number, the second mount 
command would work (of course without specifying nfsprog=...), even without 
any error/warning message in the logfiles. However, this still causes that 
both nfsd-servers are unregistered from rpc when any of both is being stopped

Is this a bug in the mount command, or did I make a mistake when I changed the 
rpc-program numbers in unfsd? (I changed them in nfs_prot.h and mount.h). At 
least 'rpcinfo -p localhost' seems to show me that unfsd is working with the 
changed rpc-number.


Thanks in advance for any help,
	Bernd





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
