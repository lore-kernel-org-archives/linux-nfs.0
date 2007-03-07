From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 22:40:54 +0100
Message-ID: <20070307224054.b2cbc294.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP3si-0000S9-9l
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:41:08 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HP3si-0008Jw-R3
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:41:10 -0800
In-Reply-To: <20070307205016.GI26553@fieldses.org>
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

> > This sounds like a job for inotify. The mountd could stat the
> > export root and use inotify_add_watch(2) to keep an eye on it to
> > see if the stat contents changed.
> Hm.  Would it be enough just to hold an open file descriptor for the
> directory?  Is it safe to assume that for any filesystem (uh, any disk
> filesystem anyway) that if you have something open then stat() on it
> won't have to go to the disk?

I think what Tom had in mind was to stat all directories once, remember
their values, have inotify keep an eye on 'em and whenever they change,
update the remembered values. This way, disk access would only have to
be done whenever something changes, which is when the disk is spun up
anyway.

Simon

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
