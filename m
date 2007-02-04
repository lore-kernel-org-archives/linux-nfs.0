From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fix rpc.gssd -d
Date: Mon, 5 Feb 2007 09:51:44 +1100
Message-ID: <17862.25472.95210.3356@notabene.brown>
References: <20070104194625.GA3000@uio.no>
	<4d569c330701041254m5a1fc1aem17a9eaadcbeaadfb@mail.gmail.com>
	<20070104235140.GA5288@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDqDb-0000uB-TY
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:52:20 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDqDW-0006DS-ED
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:52:15 -0800
In-Reply-To: message from Steinar H. Gunderson on Friday January 5
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

On Friday January 5, sgunderson@bigfoot.com wrote:
> On Thu, Jan 04, 2007 at 03:54:05PM -0500, Kevin Coffman wrote:
> > Thanks Steinar.  I'll get to this and the AM_MAINTAINER_MODE patch
> > soon and resend them to Neil.  (Your other recent patches are out of
> > my arena.)
> 
> Thanks.
> 
> By the way, I checked out the git repository (finding out the URL was
> non-trivial, though!) and discovered that the bzero patch was not applied (I
> believe it was sent in quite a while ago). Neil, did you forget, is it in
> a queue somewhere, or did I just check out the wrong one? (I used
> git://git.linux-nfs.org/pub/linux/nfs-utils/.)

  git://linux-nfs.org/nfs-utils
should be enough

I don't remember a bzero patch.  Is it just replacing the bzero in
support/nfs/svc_socket.c with a memset ??

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
