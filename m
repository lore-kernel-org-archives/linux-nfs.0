From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: File modification bug (mismatch with stat)
Date: Mon, 10 Nov 2003 09:44:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16303.42079.158426.409498@charged.uio.no>
References: <5009AD9521A8D41198EE00805F85F18F039D3C5C@sembo111.teknor.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJDHl-00006Y-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Nov 2003 06:44:57 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AJDHl-0001rQ-DC
	for nfs@lists.sourceforge.net; Mon, 10 Nov 2003 06:44:57 -0800
To: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
In-Reply-To: <5009AD9521A8D41198EE00805F85F18F039D3C5C@sembo111.teknor.com>
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

>>>>> " " == Francois Isabelle <Isabelle> writes:

     > I could but one major restriction I have is that the dump file
     > will have to be written to NFS since I'm running on a very
     > small drive, this will result in some NFS traffic on that
     > client, will it be usefull anyways ?

Could you perhaps do the tcpdump on the server instead, then? That
should be alright in this case since we're not worried about dropped
requests.
Command is the same (tcpdump -w /tmp/dumpfile.out host blah and port 2049).
Just substitute client name for "blah".

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
