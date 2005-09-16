From: Susan Champigny <schamp@ll.mit.edu>
Subject: NFS problems:
Date: Fri, 16 Sep 2005 09:57:17 -0400
Message-ID: <432ACF3D.6040900@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EGGjS-0004wG-Bs
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 06:58:26 -0700
Received: from llmail.ll.mit.edu ([129.55.12.40] helo=ll.mit.edu)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EGGjS-00013O-6b
	for nfs@lists.sourceforge.net; Fri, 16 Sep 2005 06:58:26 -0700
Received: (from smtp@localhost)
	by ll.mit.edu (8.12.10/8.8.8) id j8GDwJgC001352
	for <nfs@lists.sourceforge.net>; Fri, 16 Sep 2005 09:58:19 -0400 (EDT)
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

Recieve the following infamous error when trying to mount a directory
from a SGI Origin running 6.5 on a Linux box running Redhat Enterprise 
ES 4.0

mount: NFS version 3 mount failed; trying NFS version 2

Not sure what to do here, can someone give me some ideas.

2nd problem:

For some reason on the same SGI the nfs daemons appear to crap out, 
breaking autofs
until I run /etc/init.d/network start; to restart the network. 

Some the of errors in /var/adm/SYSLOG are:

machinename: autofsd [pid] pingnfs: nfs3 port=0 155.34.3.xx program not 
registered
machinename: autofsd [pid] pingnfs: nfs2 port=0 155.34.3.xx program not 
registered

I would appreciate any comments.

Thank you.

-- 
Susan M. Champigny
MIT Lincoln Laboratory
Space Situational Awareness Group
781-981-2918
schamp@ll.mit.edu


The information transmitted in this e-mail is intended only for the person or entity to which it is addressed and may contain confidential and/or privileged information. Any review, retransmission, dissemination or other use of or taking
of any action in reliance upon this information by persons or entities other than the intended recipient is prohibited.
If you received this e-mail in error, please contact the sender and delete the email and any attached material immediately.  Thank you.





-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
