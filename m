From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Thu, 31 Oct 2002 11:06:59 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021031.110659.42769812.taka@valinux.co.jp>
References: <15801.15328.866301.720864@notabene.cse.unsw.edu.au>
	<20021031.082927.74744491.taka@valinux.co.jp>
	<15808.28897.595522.855723@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1874rY-0007jO-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 18:15:13 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15808.28897.595522.855723@notabene.cse.unsw.edu.au>
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

> > How is it going?
> 
> I've just sent some patches to Linus and nfs@lists....

Thanks. I've seen them in linux-2.5.45.

> The rest of the zero copy stuff should fit in quite easily, with the
> possible exception of single-copy writes: I haven't looked very hard
> at that yet.

Ok,
I'll try to port the zero copy stuff on it.


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
