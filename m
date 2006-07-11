From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Function `xmalloc' implicitly converted to pointer
	at	mountpoint.c:25
Date: Tue, 11 Jul 2006 13:49:02 +1000
Message-ID: <1152589742.2863.0.camel@hole.melbourne.sgi.com>
References: <20060710231450.GB11009@debianrules.debiancolombia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G09FI-0005g0-Sq
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 20:49:13 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G09FI-0000uN-2K
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 20:49:13 -0700
To: =?ISO-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
In-Reply-To: <20060710231450.GB11009@debianrules.debiancolombia.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2006-07-11 at 09:14, An=EDbal Monsalve Salazar wrote:
> Function `xmalloc' implicitly converted to pointer at mountpoint.c:25
> =

> [0] http://bugs.debian.org/377724

Fixed in the 1.0.9 release, by commit

http://linux-nfs.org/cgi-bin/gitweb.cgi?p=3Dnfs-utils;a=3Dcommit;h=3D3bf702=
b1a914b3867117b74d519c55fa68f4dc28

Greg.
-- =

Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
