From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Thu, 5 Jun 2003 16:49:16 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0306051646490.16894-100000@stheno>
References: <3E69326E.2AF0E6F2@amis.com>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Nw2w-0005bz-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Jun 2003 07:48:54 -0700
Received: from stheno.sissa.it (stheno [147.122.2.55])
	by didot.sissa.it (8.9.3+Sun/8.9.3) with ESMTP id QAA10984
	for <nfs@lists.sourceforge.net>; Thu, 5 Jun 2003 16:49:16 +0200 (MET DST)
Received: from localhost (nesti@localhost)
	by stheno.sissa.it (8.10.2+Sun/8.10.2) with ESMTP id h55EnGJ22944
	for <nfs@lists.sourceforge.net>; Thu, 5 Jun 2003 16:49:16 +0200 (MEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <3E69326E.2AF0E6F2@amis.com>
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

Thanks for the solution to Tom Georgoulias.

This issue is solved by sun patch 108727-25.

bye,
Fabrizio

--------------------------------------------------------------------
