From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Thu, 24 Oct 2002 06:50:15 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021024.065015.74750854.taka@valinux.co.jp>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184TVV-0004Q7-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 14:57:42 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	neilb@cse.unsw.edu.au
In-Reply-To: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
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

> In particular, I think it would be good to use 'struct xdr_buf' from
> sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
> we could share some of the infrastructure.

I was thinking about the nfs clients.
Why don't we make xprt_sendmsg() use the sendpage interface instead
of calling sock_sendmsg() so that we can avoid dead-lock which 
multiple kmap()s in xprt_sendmsg() might cause on heavily loaded machines.


Thank you,
Hirokazu Takahashi.



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
