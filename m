From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance Woes...
Date: 06 Jun 2002 13:31:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1ybktzhh.fsf@charged.uio.no>
References: <F888C30C3021D411B9DA00B0D0209BE8038F9523@cvo-exchange.cvo.roguewave.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17FvUi-0000wK-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Jun 2002 04:31:57 -0700
To: Poul Petersen <petersp@roguewave.com>
In-Reply-To: <F888C30C3021D411B9DA00B0D0209BE8038F9523@cvo-exchange.cvo.roguewave.com>
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

>>>>> " " == Poul Petersen <petersp@roguewave.com> writes:

     > server? Does the NFSALL patch address any stability issues or
     > is it mostly to add V3TCP?

Nope. NFS_ALL has bugger all to do with adding TCP... The NFS client
in the standard kernel already has full support for NFS over TCP.

For info on what is in the NFS_ALL patches see the file HEADER.html in
the same directory you found the patch...

Cheers,
  Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
