From: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
Subject: RE: File modification bug (mismatch with stat)
Date: Mon, 10 Nov 2003 09:12:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5009AD9521A8D41198EE00805F85F18F039D3C5C@sembo111.teknor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJCmt-0004Lc-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Nov 2003 06:13:03 -0800
Received: from [205.205.44.10] (helo=sembo111.teknor.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AJCmt-0004xz-JA
	for nfs@lists.sourceforge.net; Mon, 10 Nov 2003 06:13:03 -0800
To: "'trond.myklebust@fys.uio.no'" <trond.myklebust@fys.uio.no>
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

I could but one major restriction I have is that the dump file will have to
be written to NFS since I'm running on a very small drive, this will result
in some NFS traffic on that client, will it be usefull anyways ?

>Message: 6
>Date: Fri, 7 Nov 2003 13:39:03 -0500
>To: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
>Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
>    "David Roy-Moder (E-mail)" <david.roy-moder@intel.com>,
>    "Ryan. J. Kummet (E-mail)" <ryan.j.kummet@intel.com>
>Subject: RE: [NFS] File modification bug (mismatch with stat)
>Reply-To: trond.myklebust@fys.uio.no
>From: Trond Myklebust <trond.myklebust@fys.uio.no>
>
>
>I know you said it was hard to reproduce, but could you still 
>try to get
>a tcpdump of this for me? Just do a standard binary dump using
>
>tcpdump -w /tmp/dumpfile.out host blah and port 2049
>
>while running your test (preferably with no other NFS traffic on that
>client). Just stop the dump as soon as you see the problem.
>
>Cheers,
>  Trond
>
>
>
>--__--__--
>
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>End of NFS Digest
>


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
