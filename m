From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [BUG] [PATCH] sunrpc may oops during initialization
 sokcets.
Date: Tue, 19 Nov 2002 17:55:10 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021119.175510.78011106.taka@valinux.co.jp>
References: <15832.11815.395760.763047@notabene.cse.unsw.edu.au>
	<20021118.202219.90829917.taka@valinux.co.jp>
	<15833.48409.629519.25149@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18E4JS-0004SB-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 01:04:54 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15833.48409.629519.25149@notabene.cse.unsw.edu.au>
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

> > I found another problem and fixed it.
> > 
> > My box has crashed in heavily loaded condition.
> > I realized there were races during initializing sunrpc sockets.

> Well caught...
> There is however a bug in your patch :-(
> 
> > +	svsk->sk_flags = SK_BUSY;
> This should be
> 	set_bit(SK_BUSY, &svsk->sk_flags);

Thanks for pointing my failure.

> I had a look at the code and did some more tidying up and
> re-organisation.
> This is what I came up with.

Your code looks much better.

Thank you,
Hirokazu Takahashi.



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
