From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs performance problem
Date: Tue, 5 Nov 2002 14:09:28 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55067@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'Benjamin LaHaise'" <bcrl@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189BtI-0007jj-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 14:09:44 -0800
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

> On a side note, make sure you have the filesystem mounted 
> with the noatime flag if you can afford losing atimes.

to be scrupulously clear, that's on the server side, not on
the client side.  the NFS client ignores the "noatime" mount
option, since file access timestamps are managed on the server.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
