From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Lock recovery doesn't work in debian statd/lockd ordering
Date: Sun, 15 Sep 2002 17:44:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020915214418.GB11002@perlsupport.com>
References: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qhCY-0005Qj-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 14:45:10 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
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

Since Neil is the bug reporter and no one has disagreed with his
analysis, I'm making the change he recommends for Debian unstable.
If it proves OK, I'll issue a fix for Debian stable.
-- 
Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
         "It furthers one to have somewhere to go."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
