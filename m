From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 15:08:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB2AF7B.B7FDC8AC@amis.com>
References: <3FB27670.4C878A84@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK39d-0002rZ-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 14:08:01 -0800
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AK39d-0002wi-7B
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 14:08:01 -0800
To: Jason Holmes <jholmes@psu.edu>
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

Jason Holmes wrote:
>
<snip>
> I'm
> already seeing some odd performance differences between the 2.4.22
> client and the 2.6.0-test9-mm1 client (both against a 2.6.0-test9-mm2
> server):

Similar observations here. Our users have reported NFS slowdowns of 10x on
2.6.0-test6-mm4 nfs clients compared to the same box and setup running 2.4.22. 
Something is goofy in 2.6.0-test6-mm4 that has a bad effect on NFS client
performance.

eric


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
