From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Fri, 20 Sep 2002 21:54:07 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15755.3167.82511.908967@notabene.cse.unsw.edu.au>
References: <20020918.160913.73658160.taka@valinux.co.jp>
	<15752.22931.241819.210428@notabene.cse.unsw.edu.au>
	<20020920.005300.74726524.taka@valinux.co.jp>
	<20020920.200508.68137471.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@math.psu.edu,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sMMe-0005ym-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 04:54:28 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <viro@math.psu.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 20 Sep 2002 21:54:13 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday September 20
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Friday September 20, taka@valinux.co.jp wrote:
> Hello,
> 
> I've checked with printk that nfsd will sleep when it find a
> freeing inode. It worked good as we expected.

Good.  This patch looks very good to me, and after understanding why
you did it differently, I see that there were problems with my
approach.

I suggest we leave it a week or so to give Al a chance for some input,
and then offer it to Linus.

Thanks,
NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
