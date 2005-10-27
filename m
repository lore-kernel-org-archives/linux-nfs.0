From: Gary Richardson <garich@ptd.net>
Subject: nfs server/clients hang after upgrade to 2.6.11-1.1180axp-smp
Date: Thu, 27 Oct 2005 10:36:55 -0400
Message-ID: <4360E607.8070205@ptd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV8t5-00032l-EP
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 07:37:51 -0700
Received: from smtpd.ha-net.ptd.net ([207.44.96.84])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EV8t1-0007mO-9M
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 07:37:48 -0700
Received: from 24.238.44.7.res-cmts.tv13.ptd.net (HELO [24.238.44.7]) ([24.238.44.7])
          (envelope-sender <garich@ptd.net>)
          by smtpd.ha-net.ptd.net (qmail-ldap-1.03) with SMTP
          for <nfs@lists.sourceforge.net>; 27 Oct 2005 14:36:59 -0000
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

after upgrading my machine alpha to alphacore nfs
the nfsserver is hanging after another client attempts
to access the server.  After trying all sort so both
server and client configurations I finally enabled
debugging.

after enabling rpc and nfs debug the server screen fills:

Want update, refage = xxx, age = xxx

What is the significance of the error message?

-- 
Gary Richardson
garich@ptd.net


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
