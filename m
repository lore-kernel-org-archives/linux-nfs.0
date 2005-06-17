From: Casey Allen Shobe <lists@seattleserver.com>
Subject: Re: NFS projects that you use
Date: Fri, 17 Jun 2005 20:15:03 +0000
Message-ID: <200506172015.03840.lists@seattleserver.com>
References: <42B30037.9080601@gmail.com> <200506171926.43758.lists@seattleserver.com> <42B3340C.1040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Oded Maimon <oded.maimon@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DjNF5-0005UL-DN
	for nfs@lists.sourceforge.net; Fri, 17 Jun 2005 13:15:07 -0700
Received: from spieden.seattleserver.com ([216.57.201.54])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DjNF4-0002VL-29
	for nfs@lists.sourceforge.net; Fri, 17 Jun 2005 13:15:07 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <42B3340C.1040408@gmail.com>
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

On Friday 17 June 2005 20:35, you wrote:
> I usually change the mail format before i send it, forgat to do
> it this time.

Why not change the default to something sensible?

> What i wanted to know is if you are using any other tools for
> performance/high avbailability/security/managing or what ever
> sepcially for NFS.

Okay, probably nothing that would really interest you then.  We do 
use DRBD (a form of network-based RAID) between our two mail 
servers along with heartbeat, each which export 5 shares, which I 
presume gives high availability.

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
