From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 1 Nov 2002 15:20:49 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15810.289.477094.931581@notabene.cse.unsw.edu.au>
References: <20021031.110659.42769812.taka@valinux.co.jp>
	<20021101.004052.85418463.taka@valinux.co.jp>
	<15809.53455.211796.730215@notabene.cse.unsw.edu.au>
	<20021101.124107.21933560.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187TIs-0004Y2-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 20:21:02 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Fri, 1 Nov 2002 15:20:54 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 1
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

On Friday November 1, taka@valinux.co.jp wrote:
> Hello,
> 
> I updated the patches.
> I'll send you 2 patches
> 
>      va-nfsd-sendpage.patch
>      va-nfsd-vfsread.patch
> 

Thanks.
I made a couple of little changes and sent them to Linus and the list.
1/ I simplified the sending of the tail a bit more.  We assume the
tail is *always* in the same page as the head, and just sendpage it.

2/ I removed svcbuf_reserve and the buffer variable from
   nfsd3_proc_readdirplus as well :-)

Thanks again,
NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
