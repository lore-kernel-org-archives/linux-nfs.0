From: Casey Allen Shobe <lists@seattleserver.com>
Subject: Re: NFS projects that you use
Date: Fri, 17 Jun 2005 19:26:43 +0000
Message-ID: <200506171926.43758.lists@seattleserver.com>
References: <42B30037.9080601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DjMUK-00033U-EX
	for nfs@lists.sourceforge.net; Fri, 17 Jun 2005 12:26:48 -0700
Received: from spieden.seattleserver.com ([216.57.201.54])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DjMUI-0003nX-24
	for nfs@lists.sourceforge.net; Fri, 17 Jun 2005 12:26:48 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <42B30037.9080601@gmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday 17 June 2005 16:54, Oded Maimon wrote:
> I'm going to use NFS in my organization and I would like to know
> about other apps that you use with NFS, things like iozone and or
> tools for security and encryption and so on. any tool that you
> use with NFS.

Your mail client is broken.  Please configure it to *not* send 
HTML-only mail.  Text-only would be much appreciated, but at 
*least* send both in multipart form.  Many of us do not have mail 
clients capable of reading HTML mail.  Many others of us, including 
myself, disable HTML support in our mail clients intentionally (I 
think it's actually the default setting in mine, but I'd turn it 
off regardless).

We use NFS to share a Portage tree (Gentoo Linux) between multiple 
servers to save disk space and CPU time (tree only has to be 
updated from NFS server).  We also use rsync+NFS for our backups, 
and distribution of scripts and configuration files between all the 
servers (cron jobs periodically copy things from an NFS share to 
corresponding directories on the root filesystems).  We have 10 
machines in one datacenter, and 1 in a remote datacenter.  They all 
have at least 5 NFS shares from other machines mounted.

All of the NFS shares are on reiserfs partitions, in case that makes 
any difference.

Cheers,
-- 
Casey Allen Shobe | http://casey.shobe.info
cshobe@seattleserver.com | cell 425-443-4653
AIM & Yahoo:  SomeLinuxGuy | ICQ:  1494523
SeattleServer.com, Inc. | http://www.seattleserver.com


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
