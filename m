From: "Paul D. Bain" <paulbain@pobox.com>
Subject: NFS over TCP -- configuring server for
Date: Sun, 18 Jan 2004 21:33:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20040118212546.057a7080@pop.erols.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: dreus@innovectra.com,pbain@innovectra.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiP6d-0005sY-VB
	for nfs@lists.sourceforge.net; Sun, 18 Jan 2004 18:25:35 -0800
Received: from smtp01.mrf.mail.rcn.net ([207.172.4.60])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiP6d-0003pS-LP
	for nfs@lists.sourceforge.net; Sun, 18 Jan 2004 18:25:35 -0800
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


         I need to know how to have my NFS services carried over TCP, not 
UDP. From postings to the Linux-NFS mailing list, I understand that I must 
recompile my server's kernel (and the client's kernel, too?) and add the 
parameter "tcp" to the file /etc/fstab on the client. What else do I need 
to do? For example, must I add anything to the file /etc/exports on the 
server?

         More generally, where can I find reliable, up-to-date information 
on NFS on Linux, other than searching the archives of this mailing list? 
The "Linux NFS-How-to" appears to be out-of-date, at least with respect to 
the topic mentioned above.

-- Paul Bain



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
