From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 01 Nov 2002 14:07:58 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021101.140758.70225466.taka@valinux.co.jp>
References: <15809.53455.211796.730215@notabene.cse.unsw.edu.au>
	<20021101.124107.21933560.taka@valinux.co.jp>
	<15810.289.477094.931581@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187U9k-00040B-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 21:15:41 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15810.289.477094.931581@notabene.cse.unsw.edu.au>
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

Hi,

> Thanks.
> I made a couple of little changes and sent them to Linus and the list.
> 1/ I simplified the sending of the tail a bit more.  We assume the
> tail is *always* in the same page as the head, and just sendpage it.

I looks fine!

> 2/ I removed svcbuf_reserve and the buffer variable from
>    nfsd3_proc_readdirplus as well :-)

Thanks.



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
