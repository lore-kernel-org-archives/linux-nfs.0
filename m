From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Thu, 24 Oct 2002 07:35:10 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021024.073510.41630026.taka@valinux.co.jp>
References: <20021023.125304.28780747.taka@valinux.co.jp>
	<20021023.144057.70224423.taka@valinux.co.jp>
	<15798.15291.519275.774315@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184UCw-0001Cw-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 15:42:34 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15798.15291.519275.774315@notabene.cse.unsw.edu.au>
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

> > > > Also, I am wondering about the way that you put zero-copy support into
> > > > nfsd_readdir.

> I think I would change the approach to buffering.
> Instead of having a fixed set of pages, we just allocate new pages as
> needed, having handed old ones over to the networking layer.
> 
> So we have a pool of pages that we draw from when generating replies,
> and refill before accepting a new request.

We can also put RPC/NFS headers on pages and send them without copy.
This seems good for NFSv4 COMPOUNDS.

> Ofcourse that is a fairly big change from where we are now so it might
> take a while.  We should probably get zero copy reads in first...

Yes.


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
