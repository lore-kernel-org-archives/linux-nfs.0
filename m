From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 01 Nov 2002 10:39:54 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021101.103954.08316364.taka@valinux.co.jp>
References: <20021031.110659.42769812.taka@valinux.co.jp>
	<20021101.004052.85418463.taka@valinux.co.jp>
	<15809.53455.211796.730215@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187QuN-0007wZ-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:47:35 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15809.53455.211796.730215@notabene.cse.unsw.edu.au>
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

> > va-nfsd-sendpage.patch        ....use sendpage instead of sock_sendmsg.
> > va-sunrpc-zeropage.patch      ....zero filled page for padding.
> > va-nfsd-vfsread.patch         ....zero-copy nfsd_read/nfsd_readdir.
> 
> A lot of this looks fine.
>
> I would like to leave the tail pointing into the end of the first page
> (just after the head) rather than using the sunrpc_zero_page thing as
> the later doesn't seem necessary.
> Also, I would like to send the head and tail with sendpage rather
> than using sock_sendmsg.

Yes, we can.
I'll do it though it seems little bit tricky.

> To give the destination address, you can call sock_sendmsg with
> a length of 0, and then call ->sendpage for each page or page
> fragment.

Ok.

> You should be able to remove the calls to svcbuf_reserve in
> nfsd_proc_readdir and nfsd3_proc_readdir, and then discard the
> 'buffer' variable as well.

Yes, you're right.

> If you could make those changes (or convince me otherwise), I will
> forward the patches to Linus,
> Thanks.

Thanks!


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
