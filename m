From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: nfsd tuning - please help me!
Date: Mon, 17 Feb 2003 10:59:22 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030217025922.GA20685@outblaze.com>
References: <20030214174453.11719.qmail@web12201.mail.yahoo.com> <200302142032.h1EKWCIJ006931@buggy.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Powell <lakerfaniam2@yahoo.com>,
	Steve Dickson <SteveD@RedHat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 202-77-223-51.outblaze.com ([202.77.223.51] helo=corpmail.outblaze.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kbU7-0007w8-00
	for <nfs@lists.sourceforge.net>; Sun, 16 Feb 2003 18:58:23 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 38FDB7F85
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 03:06:39 +0000 (GMT)
Received: from yusufg.portal2.com (202-77-223-125.outblaze.com [202.77.223.125])
	by corpmail.outblaze.com (Postfix) with SMTP id 97941520CC
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 03:06:38 +0000 (GMT)
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200302142032.h1EKWCIJ006931@buggy.badula.org>
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

Maybe RH can put their kernel's through a fstress routine

http://www.cs.duke.edu/ari/fstress/

According to the author Darell Anderson,

http://docs.freebsd.org/cgi/getmsg.cgi?fetch=1126014+0+archive/2003/freebsd-current/20030216.freebsd-current

It can emulates SPECsfs

> > Unfortunately, we've tried all that already. So given
> > that we are not hardware/network constrained, does all
> > this mean that the Linux kernel NFS runs into
> > performance issues beyond 100 file reads/sec?
> 
> It's quite possible...
> 
> What I'd recommend, however, is testing this again with a non-RedHat
> kernel on the client. More precisely, try running 2.4.20 plus the 
> NFSALL patch from Trond's site <http://www.fys.uio.no/~trondmy/src/>.
> 
> We've had significant performance problems over here with the RedHat
> kernels, which mostly went away when we replaced the NFS client code
> with 2.4.20+NFSALL.
> 
> Hope this helps,
> Ion


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
