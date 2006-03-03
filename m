From: Steven Timm <timm@fnal.gov>
Subject: NFS possible race condition, nfs_unlink vs. d_lookup
Date: Fri, 03 Mar 2006 09:57:19 -0600 (CST)
Message-ID: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FFCu3-0000hu-Ug
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 08:13:15 -0800
Received: from mailgw1.fnal.gov ([131.225.111.11])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FFCu1-0005Mf-8L
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 08:13:15 -0800
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0IVK007KV6Q1WV@mailgw1.fnal.gov> for nfs@lists.sourceforge.net;
 Fri, 03 Mar 2006 09:57:20 -0600 (CST)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2006030309571911463 for
 <nfs@lists.sourceforge.net>; Fri, 03 Mar 2006 09:57:19 -0600
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0IVK00J016W3XD@mailgw2.fnal.gov> (original mail from timm@fnal.gov)
 for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 09:57:20 -0600 (CST)
Received: from snowball.fnal.gov (snowball.fnal.gov [131.225.81.94])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with ESMTPS id <0IVK00AX66ZJZ2@mailgw2.fnal.gov> for
 nfs@lists.sourceforge.net; Fri, 03 Mar 2006 09:57:19 -0600 (CST)
Received: from snowball.fnal.gov (localhost.localdomain [127.0.0.1])
	by snowball.fnal.gov (8.13.1/8.13.1) with ESMTP id k23FvJrL012319	for
 <nfs@lists.sourceforge.net>; Fri, 03 Mar 2006 09:57:19 -0600
Received: from localhost (timm@localhost)
	by snowball.fnal.gov (8.13.1/8.13.1/Submit) with ESMTP id k23FvJAc012316	for
 <nfs@lists.sourceforge.net>; Fri, 03 Mar 2006 09:57:19 -0600
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


I found the description of an old patch against what
was then the 2.5.72 kernel.

http://kernel.tuke.sk/pub/linux/kernel/people/akpm/patches/2.5/2.5.72/2.5.72-mm3/broken-out/nfs_unlink-d_count-fix.patch

The description was the following, on that web site.

- nfs_unlink() can race with lockless d_lookup() as d_lookup() can
   successfully lookup a dentry for which nfs_unlink() can assume that no 
one
   else is using and can go ahead and do nfs_safe_remove() on it. By using
   per dentry lock, it is solved as we d_lookup() will fail the lookup for
   unhashed dentries.


My question.. is the 2.4.21-37 kernel as distributed by Red Hat also
vulnerable to this race condition? If so, is there any
patch that is available?  The code in dir.c in the 2.4 series
kernel is different enough such that this patch won't apply to it.

Thanks

Steve Timm







-- 
------------------------------------------------------------------
Steven C. Timm, Ph.D  (630) 840-8525  timm@fnal.gov  http://home.fnal.gov/~timm/
Fermilab Computing Div/Core Support Services Dept./Scientific Computing Section
Assistant Group Leader, Farms and Clustered Systems Group
Lead of Computing Farms Team


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
