From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: App hanging at NFS failure
Date: Tue, 17 Sep 2002 10:44:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54E62@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rMPS-0001dl-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 10:45:14 -0700
To: "'Magnus Naeslund(f)'" <mag@fbab.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

> If i have a program that uses sendfile to send a file to the 
> network from an NFS server (mount options: 
> rw,noatime,hard,intr,rsize=8192,wsize=8192) and reboot the 
> NFS server the program is still hung when the NFS server is 
> online again.

how long does it take to restart your NFS server?  how long do
you wait before deciding your application is hung?  oh, and
of course, which distribution and kernel version?

> When i try to strace it, it starts to run again, and works as 
> usual, the same if i debug it with gdb.

try tracing it with "echo 3 > /proc/sys/sunrpc/rpc_debug"
this produces a ton of kernel log output, but may show why
the NFS client has stopped servicing application requests.
use "echo 0 > /proc/sys/sunrpc/rpc_debug"


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
