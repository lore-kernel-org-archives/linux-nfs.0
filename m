From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] only udp calls sock_sendmsg() to set
 destination.
Date: Mon, 18 Nov 2002 20:12:21 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021118.201221.43002225.taka@valinux.co.jp>
References: <20021115.132706.26959611.taka@valinux.co.jp>
	<15832.11815.395760.763047@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DjyY-0002XE-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 03:21:58 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15832.11815.395760.763047@notabene.cse.unsw.edu.au>
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

> > I realized the first sock_sendmsg in svc_sendto() is meaningless
> > in case of TCP as the connection is already established.
> > I fixed it so that sock_sendmsg is called only if it's UDP.
> > 
> 
> Fair enough.  I'm not sure that the optimisation is likely to be
> noticable, but it is probably worth it.
> You can make the whole 'msg' structure local to the "if udp" bit, and
> do away with set_fs too as there is no data.

Good point!
I didn't realize about set_fs.

Thank you.


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
