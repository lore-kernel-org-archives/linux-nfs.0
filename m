From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Thu, 31 Oct 2002 08:29:27 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021031.082927.74744491.taka@valinux.co.jp>
References: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
	<15801.15328.866301.720864@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872P7-0008DL-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 15:37:41 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15801.15328.866301.720864@notabene.cse.unsw.edu.au>
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

How is it going?

neilb> I would make a special 'fast-path' for that case which didn't copy any
neilb> data but passed a skbuf up, and code in nfs*xdr.c would convert that
neilb> into an iovec[];
neilb> 
neilb> I am working on a patch which changes rpcsvc to use xdr_buf.  Some of
neilb> it works.  Some doesn't.  I include it below for your reference I
neilb> repeat: it doesn't work yet.  
neilb> Once it is done, adding the rest of zero-copy should be fairly easy.



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
