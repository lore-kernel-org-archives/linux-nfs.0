From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Tue, 29 Oct 2002 08:39:58 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021029.083958.74744748.taka@valinux.co.jp>
References: <20021024.103349.26272209.taka@valinux.co.jp>
	<20021027.193917.78705070.taka@valinux.co.jp>
	<15805.26221.530836.279218@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Jby-00050s-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 15:47:58 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <15805.26221.530836.279218@charged.uio.no>
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

>  - RFC1832 states that *all* variable length data must be padded with
>    zeros, and that is certainly not the case if the pages you are
>    pointing to are in the page cache.

Yes, your're right.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
