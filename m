From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 17:56:11 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17RyHb-0005Fa-00@the-village.bc.nu>
References: <Pine.LNX.3.95.1020709104427.27442B-100000@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no (Trond Myklebust), nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from lightning.swansea.linux.org.uk ([194.168.151.1] helo=the-village.bc.nu)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RxvH-00084F-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 09:33:09 -0700
To: root@chaos.analogic.com
In-Reply-To: <Pine.LNX.3.95.1020709104427.27442B-100000@chaos.analogic.com> from "Richard B. Johnson" at Jul 09, 2002 11:06:27 AM
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> > not adhere to this convention.
> 
> Well, no. It's not supported. You can't get a valid file-descriptor...

Wrong (as usual)

> If an application insists, it is up to the application to determine,
> probably once upon startup, just what kind of file synchronization
> is supported.

Linux defines fsync for directories


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
