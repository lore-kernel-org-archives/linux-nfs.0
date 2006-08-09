From: Grant Coady <gcoady.lk@gmail.com>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Wed, 09 Aug 2006 15:53:25 +1000
Message-ID: <ketid21n1s5bn108lo7ps9t8a85db5bgs9@4ax.com>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAh0q-0004pe-Ls
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 22:53:52 -0700
Received: from relay01.mail-hub.dodo.com.au ([203.220.32.149])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAh0o-0005ad-Tt
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 22:53:53 -0700
To: "Jesper Juhl" <jesper.juhl@gmail.com>
In-Reply-To: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
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

On Tue, 8 Aug 2006 16:39:54 +0200, "Jesper Juhl" <jesper.juhl@gmail.com> wrote:

>I have some webservers that have recently started reporting the
>following message in their logs :
>
>  do_vfs_lock: VFS is out of sync with lock manager!
>
>The serveres kernels were upgraded to 2.6.17.8 and since the upgrade
>the message started appearing.
>The servers were previously running 2.6.13.4 without experiencing this problem.
>Nothing has changed except the kernel.
>
>I've googled a bit and found this mail
>(http://lkml.org/lkml/2005/8/23/254) from Trond saying that
>"The above is a lockd error that states that the VFS is failing to track
>your NFS locks correctly".
>Ok, but that doesn't really help me resolve the issue. The servers are
>indeed running NFS and access their apache DocumentRoots from a NFS
>mount.
>
>Is there anything I can do to help track down this issue?

I don't have an answer, but offer this observation: five boxen running 
2.6.17.8 doing six simultaneous

  bzcat /home/share/linux-2.6/patch-2.6.18-rc4.bz2|patch -p1

didn't burp.  The /home/share/ is an NFS export from another box running 
2.4.33-rc3a, me not sure if this was exercising any NFS locking as the 
NFS source file was only opened for non-exclusive read-only.

Grant.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
