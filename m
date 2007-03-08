From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 16:46:12 -0500
Message-ID: <20070308214612.GC22713@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<200703081427.09871.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPQQY-0000HY-1B
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 13:45:34 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPQQZ-0007Sq-CU
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 13:45:35 -0800
In-Reply-To: <200703081427.09871.olaf.kirch@oracle.com>
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

On Thu, Mar 08, 2007 at 02:27:08PM +0100, Olaf Kirch wrote:
> On Wednesday 07 March 2007 22:54, J. Bruce Fields wrote:
> > 	- Maintaining a static in-kernel exports table instead of
> > 	  loading it on demand from mountd, and
> 
> Well, the original implementation did just that, and people kept
> forgetting to re-run exportfs after changing the exports table,

What exactly changed?  It's not the case today that you can expect
modifications to /etc/exports to be noticed automatically.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
