From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: File modification bug (mismatch with stat)
Date: Fri, 7 Nov 2003 13:39:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16299.59079.47817.721152@charged.uio.no>
References: <5009AD9521A8D41198EE00805F85F18F039D3C59@sembo111.teknor.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
    "David Roy-Moder (E-mail)" <david.roy-moder@intel.com>,
    "Ryan. J. Kummet (E-mail)" <ryan.j.kummet@intel.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AIBVu-0000TU-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Nov 2003 10:39:18 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AIBVu-0004Mw-9j
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 10:39:18 -0800
To: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
In-Reply-To: <5009AD9521A8D41198EE00805F85F18F039D3C59@sembo111.teknor.com>
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


I know you said it was hard to reproduce, but could you still try to get
a tcpdump of this for me? Just do a standard binary dump using

tcpdump -w /tmp/dumpfile.out host blah and port 2049

while running your test (preferably with no other NFS traffic on that
client). Just stop the dump as soon as you see the problem.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
