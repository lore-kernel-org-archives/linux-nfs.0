From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RE: 2.4.19 NFSALL performance oddity
Date: Wed, 9 Oct 2002 07:17:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54F3E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zHeo-0007gP-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 07:17:50 -0700
To: "'Heflin, Roger A.'" <Roger.A.Heflin@conoco.com>
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

> I have tried it both with and without Neil's patches, they don't
> make it better and don't make it worse.  Runing the server/client
> tcp makes things a little bit worse.
> 
> We should be using sync on the mount option, correct?  

no, only use sync in the exports file on the server.

use the sync mount option on the client only if you require
all writes to be pushed to the server's disk before the client
gives control back to your application.  (certain databases
require this option, but it is not normally needed).

> All of my tests used sync on the mount and sync in the export,
> previously when using async on 2.2.xx (on the export side), 
> and not using the sync option on the mount appeared to cause
> issues under heavy loads, ie the out of slots warnings, and
> sometimes worse.

that might be an interesting issue to pursue some time.

> I did look and it appears that how the sync option on the
> mount command changed sometime in 2001, someplace
> in the 2.4 series.

the mount command is a user-land utility.  i'm not sure
you could tie a change in its behavior to a specific
kernel version.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
