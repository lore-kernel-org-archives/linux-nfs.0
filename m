From: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
Subject: http://client.linux-nfs.org/Linux-2.6.x/2.6.10/linux-2.6.10-33-access_cache.dif
Date: Sat, 05 Feb 2005 01:50:47 -0800
Message-ID: <420496F7.9080900@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxMaS-0007oK-Hg
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 01:50:44 -0800
Received: from soda.csua.berkeley.edu ([128.32.112.233] ident=[kSXGrg4ZJ9G3U3D7mKguY8J4CMH7r1Ro])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CxMaR-00063M-6y
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 01:50:44 -0800
Received: from [127.0.0.1] (IDENT:uN9KPYPLJu5JpNKjETi2bL11GNdXx9l1@localhost [127.0.0.1])
	by soda.csua.berkeley.edu (8.12.9/8.12.6) with ESMTP id j159ogij036460
	for <nfs@lists.sourceforge.net>; Sat, 5 Feb 2005 01:50:42 -0800 (PST)
	(envelope-from mgoodman@csua.berkeley.edu)
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

This patch appears to have the effect that non-existent files don't get 
cached. When I apply it to 2.6.10, a C preprocessor workload that 
involves opening lots of non-existent files slows down by an order of 
magnitude and I notice tens of thousands of NFS ACCESS calls per second 
according to nfsstat.

Mark



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
