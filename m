From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Does Postmark correctly model email workloads
Date: Fri, 19 Mar 2004 12:14:03 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040319041403.GA30722@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4BOa-0002tS-CT
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 20:14:08 -0800
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B4BOZ-0007B4-IW
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 20:14:07 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 86D3B37B3F
	for <nfs@lists.sourceforge.net>; Fri, 19 Mar 2004 04:14:05 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id 0A56F16DD9C
	for <nfs@lists.sourceforge.net>; Fri, 19 Mar 2004 04:14:05 +0000 (GMT)
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

Looking at the source of Postmark, I don't see any fsync/O_SYNC calls. 
MTA's are very fsync intensive. As such, I am not sure if Postmark
correctly models email-intensive workloads or have I missed something
obvious ?

Paper/source on Postmark available here

http://www.netapp.com/tech_library/3022.print

Charles, any comments ? 

Regards, Yusuf


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
