From: Suresh Kodati <kodatisu@yahoo.com>
Subject: Linux NFS client over TCP
Date: Fri, 17 Oct 2003 03:59:18 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031017105918.32827.qmail@web13101.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AASLU-0005nm-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 04:00:36 -0700
Received: from web13101.mail.yahoo.com ([216.136.174.146])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1AASL6-0002LP-IA
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 04:00:12 -0700
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

Hello,
I have an NFS dir over TCP from a AIX. After 6 minutes
( ~380 secs) of idle time over the connection the
socket gets a state change, the client goes into
CLOSE_WAIT and the AIX server side goes into
FIN_WAIT_2 and eventually gets closed after
tcp_finwait2.

After the connection goes to CLOSE_WAIT from Linux
side, If I try to do some I/O over the exported
directory, the connection gets re-connected with new
port and the older connection gets teared off. ( It
seems the NFS client is trying to actually close() the
socket at the next transaction instead of closing it
on receiving FIN from the other side.).
I would like to know if this is an expected behavior
from  NFS client side?. 
Thanks 
-Suresh


__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
