From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: [GIT] NFS client fixes for 2.6.23++
Date: Fri, 19 Oct 2007 22:19:22 -0400
Message-ID: <200710200219.l9K2JMI8015439@agora.fsl.cs.sunysb.edu>
References: <1192828993.7466.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linus Torvalds <torvalds@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ij3w0-0005Kb-0H
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:19:28 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ij3w4-0003Jo-5T
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:19:33 -0700
In-reply-to: Your message of "Fri, 19 Oct 2007 17:23:13 EDT."
	<1192828993.7466.18.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

In message <1192828993.7466.18.camel@heimdal.trondhjem.org>, Trond Myklebust writes:
> Hi Linus,
> 
> Please pull from the repository at
> 
>    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git
> 
> This will update the following files through the appended changesets.
> 
>   Cheers,
>     Trond

Trond, with Linus's latest tree, you need to #include <linux/sched.h> in
fs/nfs/unlink.c, else I get:

  CC [M]  fs/nfs/unlink.o
fs/nfs/unlink.c: In function 'nfs_dec_sillycount':
fs/nfs/unlink.c:67: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in
this function)
fs/nfs/unlink.c:67: error: (Each undeclared identifier is reported only once
fs/nfs/unlink.c:67: error: for each function it appears in.)
fs/nfs/unlink.c:67: error: 'TASK_INTERRUPTIBLE' undeclared (first use in
this function)
fs/nfs/unlink.c: In function 'nfs_block_sillyrename':
fs/nfs/unlink.c:196: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in
this function)
fs/nfs/unlink.c:196: error: implicit declaration of function 'schedule'
make[2]: *** [fs/nfs/unlink.o] Error 1
make[1]: *** [fs/nfs] Error 2
make: *** [fs] Error 2

Cheers,
Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
