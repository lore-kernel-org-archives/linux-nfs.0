From: Michael Haverkamp <mhaverkamp@kcp.com>
Subject: permission denied under load
Date: Thu, 11 Nov 2004 08:48:30 -0600
Message-ID: <41937BBE.5010208@kcp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSGFc-0008Hz-Qs
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 06:48:40 -0800
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CSGFa-0001C6-PK
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 06:48:40 -0800
To: nfs@lists.sourceforge.net
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

I have a system running Gentoo Linux with a 2.6.9 kernel that is acting 
as an NFS server for several Solaris 7,8,9 systems.  Everything appears 
to work fine for a while, but at seemingly random times the clients get 
"Permission denied" when trying to access a file or directory that they 
are normally able to access.  This problem may persist for a few 
minutes, but then everything returns to normal again.  This happens 
multiple times a day.

I believe that the problem is more likely to occur under when the server 
is under a heavy load.  By intentionally stressing the nfs server, I can 
usually cause the problem to happen.  Also, the problem occurs to all 
clients at the same time when it occurs.

Does anyone know what might be causing my problem or know what can be 
done about it?


-- 
Michael Haverkamp


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
