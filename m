From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG][PATCH] NFS over TCP doesn't work on linux-2.5.43
Date: Tue, 22 Oct 2002 12:30:14 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021022.123014.78702408.taka@valinux.co.jp>
References: <20021017.220458.59648341.taka@valinux.co.jp>
	<20021018.120326.21935018.taka@valinux.co.jp>
	<15796.36961.219609.963119@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183prK-0007GI-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 20:37:34 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15796.36961.219609.963119@notabene.cse.unsw.edu.au>
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

Hello,

I looks better and I've checked it will work good!

> > I found another problem that argbuf and resbuf may be overlapped.
> > We should throw away previous one and apply a new patch.
> > 
> > > I've solved the problem that NFS over TCP doesn't work on linux-2.5.43.
> > > Could you apply it?
> > 
> 
> Thanks for noticing this. 
> I think the following it patch is simpler and achieves the same
> result.  Could you please check that it addresses the issues you
> discovered?

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of  Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576298;k?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
