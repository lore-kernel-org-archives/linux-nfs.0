From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Lock recovery doesn't work in debian statd/lockd ordering
Date: Thu, 12 Sep 2002 12:19:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJZp-0008Hp-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:19:29 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <chip@debian.org>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 12 Sep 2002 12:19:17 +1000
To: Chip Salzenberg <chip@debian.org>
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


Hi Chip and NFSers.

 I just noticed that lock recovery doesn't work with a Debian NFS
 server.
 i.e.  server shuts down, restarts, and the client *Doesn't* reclaim
 the locks.

 The problem is that statd starts before lockd.

 What happens is that:
    statd starts
      it moves everything from /var/lib/nfs/sm to /var/lib/nfs/sm.bak
      it notifies each host listed in /var/lib/nfs/sm.bak that the
        server has restarted
    statd on the client gets the notification and tells it's local
        lockd to reclaim locks.
    lockd on client asked portmap on server for port number for lockd,
        but lockd hasn't started on the server so there isn't one.  So
        lockd on the client gives up (maybe it should persist, I'm not
        sure).
    Finally lockd on the server starts, but it is too late.


 I fixed this for myself by moving /etc/rc2.d/S19nfs-common to S21 so
 that it starts after nfsd and lockd which are started in
 S20nfs-kernel-server.

 There should be no problem with statd starting after lockd and lockd
 doesn't try to talk to statd until it gets the first lock request.

NeilBrown


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
