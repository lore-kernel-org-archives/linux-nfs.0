From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Retransmissions over TCP ...
Date: Fri, 12 Sep 2003 15:26:35 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16225.22795.811584.317705@notabene.cse.unsw.edu.au>
References: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xgSz-0001xE-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 22:27:33 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xgSy-0008Jx-ST
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 22:27:33 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <amey_inamdar@yahoo.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 12 Sep 2003 15:27:29 +1000
To: =?iso-8859-1?q?Amey=20Inamdar?= <amey_inamdar@yahoo.com>
In-Reply-To: message from Amey Inamdar on Wednesday September 10
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

On Wednesday September 10, amey_inamdar@yahoo.com wrote:
> Hi,
>     I could not understand why does RPC layer
> underneath NFS client retransmit the request while
> using NFS over TCP. TCP does reliable delivery of RPC,
> ain't it?  Is it because NFS server may drop the
> requests/connection at its end?

Yes.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
