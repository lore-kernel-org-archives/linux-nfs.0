From: David Dougall <davidd@et.byu.edu>
Subject: messages in syslog
Date: Thu, 20 Jan 2005 13:07:41 -0700 (MST)
Message-ID: <Pine.LNX.4.58.0501201302230.19586@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Criax-000658-Gd
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 12:07:55 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Criaw-0007JJ-4V
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 12:07:55 -0800
Received: from lewis.et.byu.edu (lewis.et.byu.edu [128.187.112.50])
	by postal1.et.byu.edu (8.12.10/8.12.10) with ESMTP id j0KK7fiO010325
	for <nfs@lists.sourceforge.net>; Thu, 20 Jan 2005 13:07:42 -0700
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

I am seeing lots of errors in my syslog and dmesg output similar to the
following:
fh_verify: no root_squashed access at server/simulator.

They started when I upgraded to 2.4.26 a while back, but it is just
annoying that they fill up the logs, etc.
Are these benign?  What do they mean?
--David Dougall




-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
