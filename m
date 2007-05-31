From: Baurzhan Ismagulov <ibr@radix50.net>
Subject: Re: flock LOCK_EX hangs
Date: Fri, 1 Jun 2007 01:15:01 +0200
Message-ID: <20070531231501.GA12014@radix50.net>
References: <20070516131253.GC19167@radix50.net>
	<20070516173008.GD9895@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HttrW-0001O8-CJ
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 16:15:22 -0700
Received: from kz-easy.com ([85.214.25.173] helo=almaty.kz-easy.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HttrX-0007fD-UZ
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 16:15:25 -0700
Received: from alatau.radix50.net (dslb-088-064-003-136.pools.arcor-ip.net
	[88.64.3.136]) (authenticated bits=0)
	by almaty.kz-easy.com (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4VNF8RA027902
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Fri, 1 Jun 2007 01:15:10 +0200
Received: from alatau.radix50.net (localhost [127.0.0.1])
	by alatau.radix50.net (8.13.8/8.13.8/Debian-3) with ESMTP id
	l4VNF2vi012536
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Fri, 1 Jun 2007 01:15:02 +0200
Received: (from ibr@localhost)
	by alatau.radix50.net (8.13.8/8.13.8/Submit) id l4VNF1oD012515
	for nfs@lists.sourceforge.net; Fri, 1 Jun 2007 01:15:01 +0200
In-Reply-To: <20070516173008.GD9895@fieldses.org>
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

Hello Bruce,

On Wed, May 16, 2007 at 01:30:08PM -0400, J. Bruce Fields wrote:
> > I'm experiencing problems with the kernel NFS server. The client hangs
> > on the flock call.
...
> There's also been a lot fixed since 2.6.16, so it might be worth trying
> something newer.

I've tried 2.6.20, and it worked. It's amazing how long time it has been
since I had kernel bugs, I haven't even thought in that direction.
Thanks much!

With kind regards,
-- 
Baurzhan Ismagulov
http://www.kz-easy.com/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
