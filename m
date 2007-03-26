From: Jason Keltz <jas@cse.yorku.ca>
Subject: fsid question
Date: Mon, 26 Mar 2007 16:29:04 -0400
Message-ID: <46082D10.1060301@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVvoP-0002qy-7Z
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 13:29:05 -0700
Received: from bronze.cs.yorku.ca ([130.63.90.34])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVvoQ-0003Ip-BO
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 13:29:07 -0700
Received: from [130.63.86.107] (ident=jas)
	by bronze.cs.yorku.ca with esmtpsa (TLSv1:AES256-SHA:256) (Exim 4.62)
	(envelope-from <jas@cse.yorku.ca>) id 1HVvoP-0008Gr-0p
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 16:29:05 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi.

I'm running a RedHat Enterprise 4 system.

I have a question about the fsid option in /etc/exports that I was 
hoping someone might be able to help with.

I am working with LVM under Linux.  If I export LVM volumes via NFS, the 
fsid is based on major/minor number.  If I then remove a logical volume 
on the NFS server and reboot the server, the major and minor numbers for 
the other volumes are adjusted, which of course causes problems for the 
existing NFS exports (which either end up stale/pointing to a different 
logical volume)!   The fsid option would fix this by allowing me to 
specify a number independent of major/minor number.

A couple of questions:

1) How do I find out the fsid of an existing export so that I can 
"hard-code" it in the /etc/exports file?
2) For filesystems that are not mounted, how do I choose a number that 
the system will not try to allocate to a different nfs export that isn't 
using the fsid option?  Will the system check existing fsids, or it just 
allocated the fsid based on a formula?
3) What is the best way for me to generate my own fsid?

Any assistance would be appreciated...

Jason.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
