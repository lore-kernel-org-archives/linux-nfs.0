From: Craig Small <csmall@enc.com.au>
Subject: Re: NFS and fuser
Date: Mon, 29 May 2006 11:39:38 +1000
Message-ID: <20060529013938.GA2392@enc.com.au>
References: <20060528231319.GA31396@enc.com.au> <17530.13738.96859.130482@cse.unsw.edu.au> <20060528235459.GB31396@enc.com.au> <17530.15683.868564.165086@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkWjP-0006mI-Ie
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 18:39:43 -0700
Received: from ppp114-209.static.internode.on.net ([150.101.114.209] helo=mail.enc.com.au)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FkWjN-0002wT-5I
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 18:39:43 -0700
Received: from localhost (gonzo.enc.com.au [127.0.0.1])
	by mail.enc.com.au (Postfix) with ESMTP id 8D097B7A6B
	for <nfs@lists.sourceforge.net>; Mon, 29 May 2006 11:39:38 +1000 (EST)
Received: from mail.enc.com.au ([127.0.0.1])
	by localhost (gonzo.enc.com.au [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id lCGlJ5zirOvI for <nfs@lists.sourceforge.net>;
	Mon, 29 May 2006 11:39:38 +1000 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <17530.15683.868564.165086@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, May 29, 2006 at 10:16:03AM +1000, Neil Brown wrote:
> Presumably 'fuser' should only report files/directories that are
> actually 'open' inside the kernel.  Thus 'showmount -e' is 
> not appropriate.
Yes, that's right.  The typical use for it is when you are trying to
unmount a drive and it is in use, you want to know what is using it.
You don't really care what might use it, or at least if you do it is 
not fuser's job to tell you.

> I stand by my asserting that examining /proc/fs/nfs/exports is the
> best thing to do.
That's good enough for me! Thanks for your time.

 - Craig

-- 
Craig Small      GnuPG:1C1B D893 1418 2AF4 45EE  95CB C76C E5AC 12CA DFA5
Eye-Net Consulting http://www.enc.com.au/   MIEE         Debian developer
csmall at : enc.com.au                      ieee.org           debian.org


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
