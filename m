From: Ian Kent <raven@themaw.net>
Subject: Client credential message
Date: Sun, 14 Dec 2003 17:42:20 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0312141736550.32616-100000@raven.themaw.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVSl4-0007wG-PG
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 01:41:50 -0800
Received: from mail-08.iinet.net.au ([203.59.3.40] helo=mail.iinet.net.au)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AVSl4-0002z9-DD
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 01:41:50 -0800
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


Anyone have any idea what could cause messages like:

umount: Bad UMNT RPC: RPC: Authentication error;
	why = Client credential too weak

When umounting and nfs filesystem.
I can't seem to find the text of it in the kernel or util-linux anywhere.

I'm just after possible senarios. The message was seen on a RedHat 
2.4.20-20 kernel.

Ian




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
