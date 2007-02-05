From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Update README
Date: Sun, 4 Feb 2007 23:29:13 -0500
Message-ID: <20070205042913.GD12422@fieldses.org>
References: <20070201173847.GA26741@fieldses.org>
	<17862.40980.246111.403067@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDvTe-00012B-Kp
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 20:29:14 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDvTf-0005aY-Bf
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 20:29:16 -0800
In-Reply-To: <17862.40980.246111.403067@notabene.brown>
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

On Mon, Feb 05, 2007 at 02:10:12PM +1100, Neil Brown wrote:
> On Thursday February 1, bfields@fieldses.org wrote:
> > The README has bit-rotted: redhat and debian packaging scripts are no
> > longer included, util-linux mount is (in theory) no longer required, and
> > instructions on building from latest git would be useful.
> 
> Thanks.
> 
> > 
> > I'm autotool-clueless and have no clue about the "ltmain.sh" thing
> > mentioned in the last section; I just followed the bootstrapping
> > instructions in the commit message for 922d6cfd and found I needed a
> > copy of ltmain.sh to make it work.
> 
> I just run
>    ./autogen.sh

Oh, good grief.  Sometimes I really miss the ovious....

> works every time... I might change that in the README.

OK, thanks!

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
