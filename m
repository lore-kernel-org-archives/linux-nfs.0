From: Stuart Anderson <sba@srl.caltech.edu>
Subject: nfs bindresvport: Address already in use
Date: Sun, 30 Jan 2005 23:43:53 +0000 (UTC)
Message-ID: <slrncvqs9p.evp.sba@localhost.localdomain>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvOjX-0003h5-NC
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 15:43:59 -0800
Received: from naig.caltech.edu ([131.215.49.17])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CvOjW-0000bt-48
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 15:43:59 -0800
To: mlist-nfs-valinux@nntp-server.caltech.edu
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


I get the following error on the a Linux (FC3) client machine when I issue
more than 53 NFS mount requests in less than ~1 minute:

Jan 30 10:40:22 beowulf automount[22882]: >> nfs bindresvport:
	Address already in use
Jan 30 10:40:22 beowulf automount[22882]: mount(nfs): nfs:
	mount failure node54:/usr1 on /data/node54
Jan 30 10:40:22 beowulf automount[22882]: failed to mount /data/node54

If I wait ~1 minute, I can mount another set of ~50 filesystems.
The NFS servers are also running FC3.

I repeatedly get this problem whether I manually issue the mount requests
with /bin/mount or use the automounter.

I have 290 Beowulf clusters nodes that operate as NFS servers and applications
that are trying to mount these too fast and failing.

I tried running autofs-4.1.4_beta1 to rule out RedHat patches, but that
did not help.

I do not have this problem on RH9 or Solaris 9 clients.

How do I increase the rate of allowed NFS mounts?

Thanks.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
