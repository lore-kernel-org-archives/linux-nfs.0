From: "John Roberts" <john_roberts@credence.com>
Subject: Seeking NFS developer tips
Date: Fri, 1 Oct 2004 09:41:47 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200410011641.i91Gfl215449@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Cc: john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CDQTi-0002ya-Ua
	for nfs@lists.sourceforge.net; Fri, 01 Oct 2004 09:41:54 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CDQTh-00037s-Gm
	for nfs@lists.sourceforge.net; Fri, 01 Oct 2004 09:41:54 -0700
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


Hi,

I've got the Linux kernel sources and built them.
I now want to try using my hacked version of NFS.

I'm just wondering how NFS developers switch to
using their own version of NFS?

Do you copy the NFS binaries over to the kernel
directories?  Or do you hack the /etc/rc.d/init.d
script to point to a locally built binary?

Also, do you ever have to reboot Linux to restart
NFS?  Or does NFS behavior never really depend
on a "fresh" boot of the OS?


Thanks!


John Roberts

john_roberts@credence.com



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
