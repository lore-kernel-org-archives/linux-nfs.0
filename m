From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 23 Oct 2002 14:40:57 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023.144057.70224423.taka@valinux.co.jp>
References: <20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021023.125304.28780747.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184ENN-0005n0-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 22:48:17 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20021023.125304.28780747.taka@valinux.co.jp>
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

> > Also, I am wondering about the way that you put zero-copy support into
> > nfsd_readdir.
> > 
> > Presumably the gain is that sock_sendmsg does a copy into a
> > skbuf and then a DMA out of that, while ->sendpage does just the DMA.
> > In that case, maybe it would be better to get "struct page *" pointers
> > for the pages in the default buffer, and pass them to 
> > ->sendpage.
> 
> It seems good idea.
> 
> The problem is that it's hard to know when the page will be released.
> The page will be held by TCP/IP stack. TCP may hold it for a while
> by way of retransmition. UDP pakcets may also held in driver-queue
> after ->sendpage has done.
> 
> We should check reference count of the default buffer and 
> decide to use the buffer or allocate new one.
> We think Almost request can use the default buffer.

I mean we can't use a page in the default buffer.
We should use the page next to the default buffer or we should
prepare another page for nfsd_readdir.

I don't know whether allocating an extra page for each server
is good or not.
How do you think about it?

> > I would like to get the a situation where we don't need to do a 64K
> > kmalloc for each server, but can work entirely with individual pages.


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
