From: Steve Dickson <SteveD@RedHat.com>
Subject: A Question about the 2.4.21 Pathconf patch
Date: Tue, 29 Apr 2003 11:08:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAE956E.9080205@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AWip-0004Rh-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 08:08:43 -0700
Received: from RedHat.com (Suzy.Home.4Dicksons.Org [192.168.62.6])
	by Odyssey.Home.4Dicksons.Org (8.11.6/8.11.0) with ESMTP id h3TF8V006579
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 11:08:31 -0400 (EDT)
	(envelope-from SteveD@RedHat.com)
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

I noticed in the Trond's  linux-2.4.21-08-pathconf.dif patch that 
nfs_proc_fsinfo uses
the NFSPROC_STATFS instead  of (what I would expect) the NFSPROC_FSINFO
procedure as defined in the v3 spec. Now I realize  that fsinfo is not  
support in v2
but doesn't it make sense to use it with v3 or am I missing something here.
I would think that if the server sent some numbers that the client 
couldn't handle,
the client would simple fail the mount...

Has anybody tried using NFSPROC_FSINFO instead of NFSPROC_STATFS?

SteveD





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
