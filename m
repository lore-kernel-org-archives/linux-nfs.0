From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 13:22:29 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.3.95.1020709130055.377A-100000@chaos.analogic.com>
References: <E17RyHb-0005Fa-00@the-village.bc.nu>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
   linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from chaos.analogic.com ([204.178.40.224])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ryeq-00034n-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 10:20:12 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <E17RyHb-0005Fa-00@the-village.bc.nu>
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

On Tue, 9 Jul 2002, Alan Cox wrote:

> > > not adhere to this convention.
> > 
> > Well, no. It's not supported. You can't get a valid file-descriptor...
> 
> Wrong (as usual)

Really? Then what is the meaning of fsync() on a read-only file-
descriptor? You can't update the information you can't change.

This is (as usual) just an example of your helpful responses.

Cheers,
Dick Johnson

Penguin : Linux version 2.4.18 on an i686 machine (797.90 BogoMips).

                 Windows-2000/Professional isn't.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
