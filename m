From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd and krb5
Date: Thu, 16 Nov 2006 11:27:58 -0500
Message-ID: <20061116162758.GA28645@fieldses.org>
References: <200611161137.28079.hcb@chaoticmind.net>
	<4d569c330611160621w48c7a85cy9982ea8c9d96877@mail.gmail.com>
	<200611161702.38857.hcb@chaoticmind.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkk5r-0006Bj-H1
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:28:03 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gkk5r-00078K-5W
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:28:04 -0800
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <200611161702.38857.hcb@chaoticmind.net>
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

On Thu, Nov 16, 2006 at 05:02:38PM +0100, Helge Bahmann wrote:
> Am Donnerstag, 16. November 2006 15:21 schrieb Kevin Coffman:
> > I can't help directly with the locking behavior, but could it be
> > related to expiring Kerberos credentials and/or gss contexts? 
> 
> no credentials are valid
> 
> > Is the KDE startup that often triggers this at initial login, or at some
> > other time?
> 
> seems completely erratic; it happens both at initial login as well as second 
> login (after successful logout, but before credentials expire); if there is 
> any regularity at all then it seems that initial login seems more likely to 
> succeed

Is the filesystem exported under both secuirty flavors (krb5 and sys),
with the export options otherwise the same?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
