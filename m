From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] sock_writeable not appropriate for TCP sockets, for
 2.4.20
Date: Fri, 30 Aug 2002 14:28:33 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <136.727889958088$1030743336@news.gmane.org>
References: <Pine.LNX.4.44.0208301648230.1645-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: marcelo@plucky.distro.conectiva, linux-kernel@vger.kernel.org,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pizda.ninka.net ([216.101.162.242])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ktPd-0007zt-00
	for <nfs@lists.sourceforge.net>; Fri, 30 Aug 2002 14:34:41 -0700
To: cel@citi.umich.edu
In-Reply-To: <Pine.LNX.4.44.0208301648230.1645-100000@dexter.citi.umich.edu>
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

   From: Chuck Lever <cel@citi.umich.edu>
   Date: Fri, 30 Aug 2002 16:51:57 -0400 (EDT)

   patch reviewed by Trond and Alexey.  patch already sent to linus for 2.5.
   
I think this patch should go in too.
   
   --- 2.4.20-pre5/net/sunrpc/xprt.c.orig	Fri Aug 30 15:49:28 2002
   +++ 2.4.20-pre5/net/sunrpc/xprt.c	Fri Aug 30 15:52:55 2002

Franks a lot,
David S. Miller
davem@redhat.com


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
