From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: 12 Nov 2003 15:20:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssmkttk34.fsf@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK1Tl-0000yr-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 12:20:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AK1Tk-0003oM-Sq
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 12:20:41 -0800
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <3FB27670.4C878A84@psu.edu>
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

>>>>> " " == Jason Holmes <jholmes@psu.edu> writes:

     > Can someone clue me in as to why this may be happening and if
     > it's a "bug" or not?

Large numbers of 'commit' operations are a typical sign of the memory
management going wild. Have you compared this to the standard
2.6.0-test9 kernel?

What sort of load did you otherwise have on that machine?

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
