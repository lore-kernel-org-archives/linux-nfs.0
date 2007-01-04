From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: Trouble accessing NFS mountpoint as user
Date: Thu, 4 Jan 2007 22:00:41 +0100
Message-ID: <20070104210041.GA15676@janus>
References: <459CB96A.1060806@amplex.dk>
	<1167901767.6046.17.camel@lade.trondhjem.org>
	<459CD54E.9050107@amplex.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2Zhh-0003xN-Ei
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 13:00:49 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H2Zhc-00061B-Pi
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 13:00:48 -0800
To: Stephan Henningsen <sth@amplex.dk>
In-Reply-To: <459CD54E.9050107@amplex.dk>
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

On Thu, Jan 04, 2007 at 11:22:06AM +0100, Stephan Henningsen wrote:
> Trond Myklebust wrote:
> > NFS will only support a maximum of 16 supplemental groups. That is a
> > protocol limitation, not a Linux implementation issue.
> 
> I just did "chgrp dialout /var/files" on the server, changing to one of the 
> first 16 supplemental groups, and now it works.  Thank you very much for 
> solving this mystery!
> 
>  > See for instance
> > http://nfsworld.blogspot.com/2005/03/whats-deal-on-16-group-id-limitation.html 
> > if you want a more complete explanation of why this is the case.
> 
> This suggests moving from NFS3 to NFS4.  Is that an easy task?  Mount as 
> "nfs4" instead of "nfs" and compile the kernel nfs server to support nfs4?

There's an alternative: See http://www.frankvm.com/nfs-ngroups/ for a
patch to get rid of the 16 groups limit on linux NFS2/NFS3 clients without
breaking the protocol.

-- 
Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
