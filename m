From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 22:46:24 +0100
Message-ID: <20070307224624.d711f47f.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<20070307202949.GH26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP3yC-0000zq-IW
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:46:48 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HP3yC-0001Ao-3o
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:46:50 -0800
In-Reply-To: <20070307202949.GH26553@fieldses.org>
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

> 	  Though there's one point I'm unclear on: are the directories
> 	  you're exporting mountpoints?  That's the normal

Not all of my exported directories are mountpoints of the underlying
VFS of the server. Some are, though.

> 	- the filehandle->export mapping that this function tells the
> 	  kernel about is cached by nfsd for a half-hour.  That time
> is set a little later in nfsd_fh:
> 	  I don't think there would be any harm to just changing that
> 	  time(0)+30*60 to 0x7FFFFFFF (== never expire)--nfs-utils
> 	  should be invalidating that cache explicitly whenever it's
> 	  needed.  Maybe that should be the default.

I could try that for now.

Are you sure these are invalidated automatically, especially through
nfs-utils? If the kernel cache never expires, it should consequently
never ask for it, so nfs-utils would not be involved. Am I missing
something?

Simon

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
