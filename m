From: Phy Prabab <phyprabab@yahoo.com>
Subject: mtab and procs not in sync?
Date: Tue, 8 Jun 2004 11:20:36 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608182036.78593.qmail@web51805.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXlDK-0001pU-8s
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 11:20:46 -0700
Received: from web51805.mail.yahoo.com ([206.190.38.236])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BXlDJ-0005M9-Vo
	for nfs@lists.sourceforge.net; Tue, 08 Jun 2004 11:20:46 -0700
To: nfs@lists.sourceforge.net
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

Hello,

Have run into a situation where mtab does not match
/proc/mounts in that mtab has numerous entries that
have expired off and removed, yet does not show that
it has been removed from mtab.  Is this known and is
there a fix?

Kernel 2.4.21 and 23
nfs-utils 1.06
automount 4.1.2

Thanks!
Phy


	
		
__________________________________
Do you Yahoo!?
Friends.  Fun.  Try the all-new Yahoo! Messenger.
http://messenger.yahoo.com/ 


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
