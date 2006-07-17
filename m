From: Neil Brown <neilb@suse.de>
Subject: Re: NFS export/mount problem ERR_ACCESS for exported mount
	point
Date: Tue, 18 Jul 2006 09:44:27 +1000
Message-ID: <17596.8411.211050.655554@cse.unsw.edu.au>
References: <44BB9F3D.14211.1695037@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2cly-0003hG-59
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 16:45:10 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G2clx-0004KS-9N
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 16:45:10 -0700
To: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
In-Reply-To: message from Ulrich Windl on Monday July 17
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

On Monday July 17, ulrich.windl@rz.uni-regensburg.de wrote:
> Hi,
> 
> I have a problem with Linux (2.6.5-7.267-smp) not letting me mount a filesystem 
> via NFS that I have exported. The exported path is a mount point where some CIFS 
> filesystem is mounted.

I'm sorry, but this is not supportable with NFS.
NFS make demands of the filesystem that a network filesystem like CIFS
would find it very hard to meet.  This is particularly related to
mapping from an NFS file handle to an actual file in the filesystem.

You will need to find a different way to solve your problem.

The "user space" nfs server does have a --re-export option and it does
work to some extent, but there are plenty of scenarios where it would
perform very poorly or fail completely.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
