From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: NFSv4 daemons...
Date: Thu, 08 Jan 2004 19:34:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1073608448.1380.22.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AekbN-0006jA-9E
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 16:34:13 -0800
To: hjl@users.sourceforge.net
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


We're at the point now with the NFSv4 project that we'd like to publish
the user daemons that are necessary to support the existing client in
the 2.6.0 kernel.

Would it make sense to add these to the existing nfs-utils package?


There are basically 2 daemons required on the client side:

  - Idmapper resolves NFSv4 over-the-wire names into uids/gids that can
be understood by the kernel.

  - rpc.gssd sets up RPCSEC_GSS sessions to allow secure RPC negotiation
between the client and server. Initial support is for Kerberos 5, but
SPKM3 is in the pipeline too.

Both these two daemons have equivalents on the server side (but I'll
leave it to CITI/Neil to work out who wants to take responsability for
publishing those).

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
