From: Joel Votaw <jovotaw@cs.nmsu.edu>
Subject: Re: Stale file handle, kernel 2.4.7, RedHat 7.2
Date: Thu, 19 Sep 2002 15:25:45 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209191524260.3982-100000@quito>
References: <Pine.LNX.4.44.0209190916140.2466-100000@quito>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cs.nmsu.edu ([128.123.64.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s8o2-0000L5-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 14:25:50 -0700
Received: from quito (IDENT:1628@quito [128.123.64.162])
	by mail.cs.nmsu.edu (8.11.6/8.11.5) with ESMTP id g8JLPjs01618
	for <nfs@lists.sourceforge.net.>; Thu, 19 Sep 2002 15:25:45 -0600 (MDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0209190916140.2466-100000@quito>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


I think I figured this out.  It turns out that while stopping and
restarting NFS services I also deleted /var/lib/nfs/xtab .  Don't ask
how... it was pilot error on my part.

	-Joel




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
