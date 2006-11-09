From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix spurious error return from nfsd_create
	in async case
Date: Wed, 8 Nov 2006 21:53:47 -0500
Message-ID: <20061109025347.GB1734@fieldses.org>
References: <20061101021647.GA4203@schwan.zoo>
	<20061108234515.GD16390@fieldses.org>
	<20061109004909.GA30367@fieldses.org>
	<17746.33908.348544.679986@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, aime.le-rouzic@bull.net,
	nfs@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>,
	Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi03A-0001E9-N5
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 18:53:56 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi03A-0003Fb-JC
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 18:53:58 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17746.33908.348544.679986@cse.unsw.edu.au>
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

On Thu, Nov 09, 2006 at 12:29:24PM +1100, Neil Brown wrote:
> Thanks Bruce.  I checked the rest of that commit and I don't think the
> same problem occurs anywhere else.

Good, thanks, I didn't think to do that.

> There is an 'err = nfserr_acces' in nfsd_lookup which is now dead
> code... but I guess it already was before the patch.
> 
> That "err = " that you fixed was dead code before the patch, but
> became a live problem.....

Yeah, that probably contributed to the confusion.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
