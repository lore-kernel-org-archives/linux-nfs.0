From: Olaf Kirch <okir@suse.de>
Subject: nfs3 dentry encoding
Date: Thu, 27 May 2004 12:20:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527102049.GI12225@suse.de>
References: <20040518112921.15964.patches@notabene> <E1BPtSE-0004BX-SL@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTI0L-0006PM-RO
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 03:20:53 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BTI0L-0004Tf-Cq
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 03:20:53 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1BPtSE-0004BX-SL@notabene.cse.unsw.edu.au>
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

Hi Neil,

you recently posted a patch that should fix readdir encoding in
nfsd. You say there

	Note that as the offset and whole response is known to be
	4byte-aligned, the offset pointer will never be split over
	two pages.

This is not true. The dirent offset is a 64bit quantity, so it's quite
possible it will be split across the page boundary. I'm working on a
patch...

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
