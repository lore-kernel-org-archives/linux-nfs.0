From: David Dougall <davidd@et.byu.edu>
Subject: Performance tuning
Date: Wed, 10 Jul 2002 09:15:49 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0207100905100.27879-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from email1.byu.edu ([128.187.22.133])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SJCI-0004N6-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 08:16:06 -0700
Received: from lewis ([128.187.112.50]) by EMAIL1.BYU.EDU (PMDF V6.1-1 #30538)
 with ESMTP id <01KJXAP9UC1U8Y5LXU@EMAIL1.BYU.EDU> for
 nfs@lists.sourceforge.net; Wed, 10 Jul 2002 09:15:50 -0600 (MDT)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Looking through the nfs-howto chapter 5 "Optimizing NFS Performance", I
found a few ambiguous statements and was wondering if I could get some
clarification.
There is a suggestion to increase rmem_default and rmem_max in
/proc/sys/net/core to "at least 256k".  What is the limit on that?  If I
have a server withs gobs of memory, how high can I increase that to still
get performance improvements.  Are there some statistics I can use to
measure if increases in this are helping.  Also, should I also increase
wmem_default and wmem_max.  It makes no mention of that in the howto.

With respect to Overflow of fragmented packets, it mentions the 2.2
kernel, but never mentions the 2.4.  Is it the same?  If so, it might be
nice to clear that up in the howto.  It also states that there is no ideal
value for this.  Any suggestions for specific traffic patterns?

Thanks
--David Dougall






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
