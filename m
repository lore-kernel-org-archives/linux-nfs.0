From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RPC: Unable to allocate resbuf from cache!
Date: 01 Apr 2002 23:02:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shselhz6sk7.fsf@charged.uio.no>
References: <200203251617.g2PGHwZ19460@roma.math.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16s8x0-00073c-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Apr 2002 13:02:51 -0800
To: Andrew Schretter <schrett@math.duke.edu>
In-Reply-To: <200203251617.g2PGHwZ19460@roma.math.duke.edu>
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

>>>>> " " == Andrew Schretter <schrett@math.duke.edu> writes:

     > RPC: Unable to allocate resbuf from cache!

     > Is this something to be concerned about?  Is there a setting to
     > change to reduce the number of warnings?

It means that you are sometimes running short on memory. Probably due
to high traffic. It shouldn't really be much of a problem, but if the
warnings become to pesky, either disable the printk in
net/sunrpc/svcsock.c, or just set the console logging level to some
value < 4 (== KERN_WARNING).

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
