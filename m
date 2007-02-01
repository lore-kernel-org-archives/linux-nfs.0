From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Fri, 2 Feb 2007 09:39:21 +1100
Message-ID: <17858.27673.476380.463938@notabene.brown>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
	<9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	<17641.10665.116168.867041@cse.unsw.edu.au>
	<1156190098.6158.109.camel@localhost>
	<17853.33116.113629.65031@notabene.brown>
	<1170080210.5757.6.camel@lade.trondhjem.org>
	<9a8748490701301542r33317ca7id9deb63fca2fb2dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Jesper Juhl" <jesper.juhl@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCkaw-0004x4-It
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 14:39:54 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCkaw-0007Ig-4F
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 14:39:56 -0800
In-Reply-To: message from Jesper Juhl on Wednesday January 31
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

On Wednesday January 31, jesper.juhl@gmail.com wrote:
> On 29/01/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> Finally getting that in will be sooooo nice :-)  Thank you.
> 
> Btw: any reason why not to include the
>   fl->fl_flags &= ~FL_SLEEP;
> bit as well?  As in http://lkml.org/lkml/2006/11/27/41  ??
> 

Uhmm... I guess I had forgotten it ....

Looking again, I cannot convince myself that it is needed.
The comment says "If we were signalled ...", and if we were signalled
then do_vfs_lock won't block anyway.  I think I was probably being
over-cautious as I didn't know the significance of testing for
-ERESTARTSYS.
However it seems to only get returned if a signal is pending (so why
EINTR isn't returned I still don't know) so a signal must be pending
on that piece of code, so there is no need to clear FL_SLEEP.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
