From: David Dougall <davidd@et.byu.edu>
Subject: Re: trouble with file locking
Date: Wed, 19 Nov 2003 13:02:17 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMYXO-0003r3-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 12:02:54 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMYXO-0006A5-0C
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 12:02:54 -0800
Received: from mail by postal1.et.byu.edu with local (Exim 4.20)
	id 1AMYWo-0008Ao-7o
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 13:02:18 -0700
To: Erik Thiele <erik@thiele-hydraulik.de>
In-Reply-To: <20031112105043.020c1548.erik@thiele-hydraulik.de>
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

Is this test program run on a HP-UX client or a linux client?  My
experience with HP-UX nfs client is that locking is very flaky if it even
works at all.  You might try flock instead of fcntl.  That seems to work
better.  You might also, if you have a support contract, check out HP-UX
nfs patches.  They might suddenly make it work.
--David Dougall


On Wed, 12 Nov 2003, Erik Thiele wrote:

> Hi.
>
> I am using as a fileserver
>
> ii  nfs-kernel-ser 1.0-2woody1    Kernel NFS server support
> ii  kernel-image-2 2.4.18-5       Linux kernel image for version 2.4.18 on AMD
> ii  nfs-common     1.0-2woody1    NFS support files common to client and serve
>
> on a AMD K6-2/400 with 128MB Ram.
>
> the server has / mounted as ext2.
>
> i am exporting to old hp-ux machines a subdirectory of / like this:
>
> /Archiv xxx.unix.yyy-intern(rw,no_root_squash)
>
> i also export my homedirectory to my linux woody debian machines like this:
>
> /home/erik str.blafoo-intern(rw,no_root_squash)
>
>
> i have written a test-program like this:
>
> #include <unistd.h>
> #include <stdio.h>
> #include <fcntl.h>
> #include <string.h>
>
> int main()
> {
>   int h=open("delmelockfile", O_WRONLY|O_CREAT, 0700);
>   struct flock l;
>   memset(&l,0,sizeof l);
>   l.l_type=F_WRLCK;
>   l.l_whence=SEEK_SET;
>   l.l_start=0;
>   l.l_len=0;
>   fcntl(h,F_SETLK,&l);
>   sleep(100);
>   return 0;
> }
>
> i strace it, and it gets a no lock availiable error on the fcntl.
> i use ethereal to analyze traffic and get a V4 LOCK CALL with the right inode,
> and a V4 xxxxxx (i forgot to write) which has a NLM_DENIED or NLM_NO_LOCKS or something like that.
>
> using rpcinfo i found nlockmgr running.
> now if i restart the rpc.statd (!!!) suddenly it works and i get locks granted packages (NLM_GRANTED)
>
> someone please enlighten me :)
>
> cu
> erik
>
>
> -------------------------------------------------------
> This SF.Net email sponsored by: ApacheCon 2003,
> 16-19 November in Las Vegas. Learn firsthand the latest
> developments in Apache, PHP, Perl, XML, Java, MySQL,
> WebDAV, and more! http://www.apachecon.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>


______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
