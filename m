From: Brett Petrusek <brettp@aspsys.com>
Subject: NFS IA32 server / IA64 client problems
Date: Tue, 23 Aug 2005 16:44:43 -0600
Message-ID: <430BA6DB.7080907@aspsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E7hS1-0002jv-WE
	for nfs@lists.sourceforge.net; Tue, 23 Aug 2005 15:41:02 -0700
Received: from [216.150.199.16] (helo=mail.aspsys.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E7hS0-0001KP-SB
	for nfs@lists.sourceforge.net; Tue, 23 Aug 2005 15:41:02 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.aspsys.com (Postfix) with ESMTP id 4EDD769000B
	for <nfs@lists.sourceforge.net>; Tue, 23 Aug 2005 16:40:59 -0600 (MDT)
Received: from [192.168.0.38] (unknown [192.168.0.38])
	by mail.aspsys.com (Postfix) with ESMTP id 82A3B690008
	for <nfs@lists.sourceforge.net>; Tue, 23 Aug 2005 16:40:58 -0600 (MDT)
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

I posted a question about this problem a couple of weeks ago but did not 
recieve any responses. I am having severe performance issues transfering 
files between an ia64 NFS server and ia32 NFS client (and vice versa). 
Networking has been completely ruled out as an issue. What I'm really 
wanting to know is if anyone else is experiencing these problems. I have 
been able to reproduce this problem is several different configurations 
and locations. If you can name the OS/kernel/nfs version, I have used 
it, and all of them come up with similar results (NFSv4 actually 
performs worse). I can provide any information requested, but as this 
problems occurs on almost all flavors of linux and all kernel versions, 
I'm not sure how useful it would be.

Please let me know if anyone else is experiencing similar performance 
degredation on cross architecture NFS transfers.

Brett P


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
