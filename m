From: "Cole, Timothy D." <tdcole@northropgrumman.com>
Subject: RE: Re: broken umount -f
Date: Tue, 14 Jan 2003 11:49:55 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7F21D7A9E7D9D51192CB0002A53F93C73C28E6@xcgmd024.md.essd.northgrum.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from xcgtx811.northgrum.com ([208.20.220.57])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YX9g-0008QO-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:55:24 -0800
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

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Tuesday, January 14, 2003 14:36
> To: Scott Mcdermott
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Re: broken umount -f
> 
> They will if you mount with 'intr', and make sure that you kill *all*
> programs that are using that mountpoint.

That doesn't always appear to be the case in practice (maybe a long-standing
bug/strange interaction?).  Can there be users not reported by fuser?



-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
