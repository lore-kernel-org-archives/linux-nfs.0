From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: Broken umount -f
Date: Thu, 16 Jan 2003 14:56:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030116195633.GE3473@questra.com>
References: <7F21D7A9E7D9D51192CB0002A53F93C73C28EA@xcgmd024.md.essd.northgrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZG7v-0006KP-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 11:56:35 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 0AD4AAB822
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 14:56:34 -0500 (EST)
To: "Cole, Timothy D." <tdcole@northropgrumman.com>
In-Reply-To: <7F21D7A9E7D9D51192CB0002A53F93C73C28EA@xcgmd024.md.essd.northgrum.com>
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

Cole, Timothy D. on Thu 16/01 11:45 -0800:
> > But, I still think that with `intr', umount -f should work.
> 
> Agreed on that count -- I didn't really mean to suggest otherwise.

I meant, that with `nointr' it should work.  I made a couple of typos in
that email :)

> Unmounting is orthagonal to signal delivery, so really intr/nointr
> shouldn't influence umount -f's behavior.

as it is now, with `nointr' the signals aren't delivered when there is
pending IO, apparently (don't know if that's what really happens in the
kernel)

> > btw the NFS HOWTO recommends hard,nointr
> 
> I think there was a typo in an some earlier versions -- the current
> version of the NFS HOWTO
> (http://nfs.sourceforge.net/nfs-howto/client.html) recommends
> hard,intr.

I think I read it wrong.  I seem to have dyslexia or something...

anyways thanks to all for this useful discussion, I have remounted my
systems with intr and that solution is good enough for now.


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
