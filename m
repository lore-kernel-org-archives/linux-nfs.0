From: Bruce Allan <bwa@us.ibm.com>
Subject: Please ignore previous message [PATCH] nfs-utils: NFSv4
 pseudofilesystem mount of missing directory fails
Date: Fri, 04 Feb 2005 16:16:30 -0800
Message-ID: <1107562590.4412.168.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxDd0-0004b5-Oy
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 16:16:46 -0800
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CxDcy-0004bK-5R
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 16:16:46 -0800
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j150GbH5187724
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 19:16:37 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j150GbHI214678
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 17:16:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j150GagU015750
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 17:16:36 -0700
Received: from w-bwa3.beaverton.ibm.com (w-bwa3.beaverton.ibm.com [9.47.22.65])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j150GaGi015606
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 17:16:36 -0700
To: linux-nfs <nfs@lists.sourceforge.net>
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

Patch needs some reworking :-(



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
