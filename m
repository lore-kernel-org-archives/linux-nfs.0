From: Mark Hemment <markhe@veritas.com>
Subject: Re: Reply-cache
Date: Mon, 11 Aug 2003 11:11:01 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308111101410.1069-100000@localhost.localdomain>
References: <16182.52917.693714.6285@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay-bridge.veritas.com ([143.127.3.10] helo=mtvmime03.VERITAS.COM)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19m9d0-0004LU-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Aug 2003 03:10:14 -0700
Received: from localhost.localdomain(markhe.wat.veritas.com[10.10.185.104]) (1273 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m19m9cu-00008iC@megami>
	for <nfs@lists.sourceforge.net>; Mon, 11 Aug 2003 03:10:08 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16182.52917.693714.6285@gargle.gargle.HOWL>
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

On Mon, 11 Aug 2003, Neil Brown wrote:
>
> > 3) For non-idempotent operations, hold an "inprogress-entry" in the
> >    reply-cache?
> >
> Doest "RC_INPROG" work for you as an inprogress-entry?  If so, it is
> already implemented.

  Yes, "RC_INPROG" works as an inprogress-entry.

> But read operations and getaddr are idempotent, not non-idempotent, so
> either you or I are a bit confused.

  It is me that is confused....

Mark



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
