From: "Cole, Timothy D." <tdcole@northropgrumman.com>
Subject: RE: Re: Broken umount -f
Date: Thu, 16 Jan 2003 11:45:08 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7F21D7A9E7D9D51192CB0002A53F93C73C28EA@xcgmd024.md.essd.northgrum.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from xcgmd811.northgrum.com ([155.104.240.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZFww-00053T-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 11:45:14 -0800
To: 'Scott Mcdermott' <smcdermott@questra.com>, nfs@lists.sourceforge.net
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
> From: Scott Mcdermott [mailto:smcdermott@questra.com]
> Sent: Wednesday, January 15, 2003 22:38
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Re: Broken umount -f

> But, I still think that with `intr', umount -f should work.

Agreed on that count -- I didn't really mean to suggest otherwise.
Unmounting is orthagonal to signal delivery, so really intr/nointr shouldn't
influence umount -f's behavior.

> btw the NFS HOWTO recommends hard,nointr

I think there was a typo in an some earlier versions -- the current version
of the NFS HOWTO (http://nfs.sourceforge.net/nfs-howto/client.html)
recommends hard,intr.


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
