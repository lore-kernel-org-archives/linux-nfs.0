From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 14:27:08 +0100
Message-ID: <200703081427.09871.olaf.kirch@oracle.com>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPIed-0001SM-2M
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:27:35 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPIee-0004hr-LI
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:27:37 -0800
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l28DRSem031257
	for <nfs@lists.sourceforge.net>; Thu, 8 Mar 2007 06:27:28 -0700
Received: from rcsmt251.oracle.com (rcsmt251.oracle.com [148.87.90.196])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l28AXdg3002242
	for <nfs@lists.sourceforge.net>; Thu, 8 Mar 2007 06:27:27 -0700
In-Reply-To: <20070307215406.GR26553@fieldses.org>
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

On Wednesday 07 March 2007 22:54, J. Bruce Fields wrote:
> 	- Maintaining a static in-kernel exports table instead of
> 	  loading it on demand from mountd, and

Well, the original implementation did just that, and people kept
forgetting to re-run exportfs after changing the exports table,
and whatnot. Lots of gross inconsistencies. The addition of a
dynamic exports table was considered a sliced bread kind of
innovation... so it does feel like time warp when we talk about
a static export table now.

> 	- divorcing the exports namespace completely from any local
> 	  process namespace, to the extent that you could even just say
> 	  "I want to export /dev/sda7 as /usr/local/bin" without first
> 	  mounting /dev/sda7 someplace.

Is that really a desirable goal? From an admin's point of view,
file names are usually more "natural" than using fs uuids or
retro stuff such as device file names (the udev people would
actually hit you with their "device numbers are smoke and mirrors"
bat now).

Users actually want things like "I export /mnt and then clients
can see the contents of the CD mounted on /mnt/cdrom"

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
