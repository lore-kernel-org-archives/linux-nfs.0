From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Hang when shutting down - seems umount and NFS related -
 kernel version 2.6.18.1
Date: Mon, 26 Feb 2007 18:19:07 -0500
Message-ID: <45E36AEB.7030800@redhat.com>
References: <9a8748490702261504n147aa444y779153c03a2d44a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLp7o-0002Rc-4C
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 15:19:20 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLp7o-00073L-Tz
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 15:19:22 -0800
In-Reply-To: <9a8748490702261504n147aa444y779153c03a2d44a2@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Jesper Juhl wrote:
> I have a server that has the sole job of serving up a bunch of NFS
> filesystems to webservers. The server is running kernel 2.6.18.1
> 
> A few days ago when attempting to reboot the server, the shutdown
> process hung with a backtrace on the console. A photo was taken and is
> available here:
>  http://www.kernel.org/pub/linux/kernel/people/juhl/images/DSC00504.jpg
> 
> A quick (incomplete) text transcript of the photo is here:
> 
> EIP: [<c01a51a0>] nfs_clear_inode+0x61/0x6b SS:ESP 0068:eb476ee4
> BUG: warning at kernel/exit.c:855/do_exit()

The real oops has scrolled off the screen.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
