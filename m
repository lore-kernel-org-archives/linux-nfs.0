From: James Pearson <james-p@moving-picture.com>
Subject: NFS server stalls with 2.4.18 + XFS 1.1
Date: Thu, 04 Jul 2002 17:16:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ag1sg0$348$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Q9HI-00038p-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 09:16:20 -0700
To: nfs@lists.sourceforge.net, linux-xfs@oss.sgi.com
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

We have noticed a problem with a couple of our NFS servers (running
RedHat 7.2 with a stock 2.4.18 kernel with XFS v1.1) whereby NFS access
slows to a crawl or stalls.

The exported filesystem(s) are XFS with 8 nfsd's running - when we have
the problem the load average is about 8 - but CPU usage, disk access and
network traffic are minimal.

I found, by accident, that running the command 'sync' appears to 'fix'
the situation...

I'm not sure if this is an XFS or NFS related problem (hence posting to
both lists).

Thanks

James Pearson


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
