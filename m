From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock manager!
Date: Tue, 8 Aug 2006 16:39:54 +0200
Message-ID: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GASkR-0002nd-6v
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:39:59 -0700
Received: from wr-out-0506.google.com ([64.233.184.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GASkO-0006aD-ED
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:39:59 -0700
Received: by wr-out-0506.google.com with SMTP id 69so85899wri
	for <nfs@lists.sourceforge.net>; Tue, 08 Aug 2006 07:39:55 -0700 (PDT)
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
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

I have some webservers that have recently started reporting the
following message in their logs :

  do_vfs_lock: VFS is out of sync with lock manager!

The serveres kernels were upgraded to 2.6.17.8 and since the upgrade
the message started appearing.
The servers were previously running 2.6.13.4 without experiencing this problem.
Nothing has changed except the kernel.

I've googled a bit and found this mail
(http://lkml.org/lkml/2005/8/23/254) from Trond saying that
"The above is a lockd error that states that the VFS is failing to track
your NFS locks correctly".
Ok, but that doesn't really help me resolve the issue. The servers are
indeed running NFS and access their apache DocumentRoots from a NFS
mount.

Is there anything I can do to help track down this issue?

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
