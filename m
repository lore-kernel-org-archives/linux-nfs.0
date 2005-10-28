From: stanojr@blackhole.websupport.sk
Subject: CAP_DAC_OVERRIDE on nfs
Date: Fri, 28 Oct 2005 20:06:33 +0200
Message-ID: <20051028180633.GB6852@blackhole.websupport.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVYce-0007sb-LX
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 11:06:36 -0700
Received: from blackhole.sk
	([86.110.225.103] helo=blackhole.websupport.sk ident=postfix)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EVYce-0006N3-7U
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 11:06:36 -0700
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

Hello,

When process with CAP_DAC_OVERRIDE capability on nfs client tried
to access file or directory on nfs mount where it does not have acces, it got access denied.
On local fs it work as expected. (CAP_DAC_OVERRIDE bypass filesystem access permission on process
with uid!=0)
I am using 2.6.13.4 kernel on client and server and nfs mount is exported with no_root_squash. 

This is feature or bug ?

stanojr
sorry for english


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
