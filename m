From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File modification bug (mismatch with stat)
Date: 07 Nov 2003 12:21:38 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0b8qel9.fsf@charged.uio.no>
References: <5009AD9521A8D41198EE00805F85F18F039D3C55@sembo111.teknor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	  "David Roy-Moder (E-mail)" <david.roy-moder@intel.com>,
	  "Ryan. J. Kummet (E-mail)" <ryan.j.kummet@intel.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AIAIw-0006qk-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Nov 2003 09:21:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AIAIv-0007B1-Ok
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 09:21:49 -0800
To: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
In-Reply-To: <5009AD9521A8D41198EE00805F85F18F039D3C55@sembo111.teknor.com>
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

     > Size : 9586 , time: 1068133738 <= Real time Size : 9586 , time:
     > 1068141476 <= Time got higher for a little while Size : 9586 ,
     > time: 1068141476 Size : 9586 , time: 1068141476 Size : 9586 ,
     > time: 1068133738 <= Time got back to normal on file

     > All calls to 'stat' occured in the same second.

I assume nobody was writing to the file at the time (either on the
client or the server)?

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
