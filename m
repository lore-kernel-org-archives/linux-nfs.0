From: Robert Sander <ml-linux-nfs@epigenomics.com>
Subject: nfs client's local cache
Date: Fri, 31 Oct 2003 16:28:50 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <news2mail-slrnbq53e2.8a3.gurubert-dated-1067588488.lakkeclf@moneta.epigenomics.epi>
Reply-To: Robert Sander <gurubert-dated-1067588488.lakkeclf@epigenomics.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFc8u-0006qz-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Oct 2003 08:28:56 -0800
Received: from gk.ka.epigenomics.net ([62.159.77.106] ident=qmailr)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AFc8t-0004AT-BB
	for nfs@lists.sourceforge.net; Fri, 31 Oct 2003 08:28:55 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi!

I have a questions that may be a FAQ:

An NFS client machine has several processes that open a file on a NFS
server read-only for quite a long time (server processes).

The file gets replaced on the NFS server.

The client processes still have the old copy open.

A new process on the NFS client also only sees the old copy of that
file. Only after the running processes are killed or close() the
filehandle and the filesystems gets remounted the NFS client machine
sees the new version of that file.

Is that expected behaviour? Is there any local NFS client cache timeout
involved?

Greetings
-- 
Robert Sander
Manager
Information Systems        www.epigenomics.com        Kastanienallee 24
+493024345330                                              10435 Berlin


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
