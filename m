From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 15:50:17 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <agff7l$91l$2@main.gmane.org>
References: <E17S18w-0005a7-00@the-village.bc.nu>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
   linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from chaos.analogic.com ([204.178.40.224])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17S101-0002m6-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 12:50:13 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <E17S18w-0005a7-00@the-village.bc.nu>
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

> > That is what it's supposed to do with files. The attached code clearly
> > shows that it doesn't work with directories. The fsync() instantly
> > returns, even though there is buffered data still to be written.
> 
> Your understanding or code is wrong. Its hard to tell which.
> 
> fsync on the directory syncs the directory metadata not the file metadata
> 

Well the original complaint was that Linux NFS didn't allow a directory to
be fsync()ed. I showed that POSIX.4 doesn't provide for fsync()ing
directories, only files, that you have to fsync() individual files, not
the directories that contain them. Others said that fsync()ing individual
files was not necessary, that you only have to fsync() the directory. I
explained that you have to cheat to even get a fd that can be used
to fsync() a directory. Then I showed that fsync()ing a directory in this
manner doesn't work so, we are actually in violent agreement.


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
