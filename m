From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 14:28:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16307.56177.201476.874932@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
	<shssmkttk34.fsf@charged.uio.no>
	<3FB29D43.A618973D@psu.edu>
	<16306.41898.291062.36209@charged.uio.no>
	<3FB2A738.3F2C90B8@psu.edu>
	<16306.49310.195265.145519@charged.uio.no>
	<3FB2DC60.FA7D3E08@psu.edu>
	<16306.59249.857512.354675@charged.uio.no>
	<3FB3A99F.126920E7@amis.com>
	<16307.50555.813132.978552@charged.uio.no>
	<3FB3D48D.67E9A28F@amis.com>
	<3FB3D6EC.E4F1FF17@amis.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKN9K-000800-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 11:29:02 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKN9K-0006IJ-1H
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 11:29:02 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3FB3D6EC.E4F1FF17@amis.com>
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

>>>>> " " == Eric Whiting <ewhiting@amis.com> writes:

     > 2.6.0-test9 (without mm1 4/4 vm) is even worse than
     > 2.6.0-test6-mm4.

     > tcpdump shows very slow writes..


Were you filtering away replies from the server, or were they really
missing? If the latter, then that points towards a problem in the
socket layer or possibly a problem with the device driver for your
NIC.

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
