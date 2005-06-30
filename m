From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange problem with ACL over NFS
Date: Thu, 30 Jun 2005 20:58:48 +0200
Message-ID: <1120157929.8922.14.camel@lade.trondhjem.org>
References: <42C3DBDC.5050803@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Do4Fj-0004zw-8u
	for nfs@lists.sourceforge.net; Thu, 30 Jun 2005 11:59:11 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Do4Fi-00073x-3i
	for nfs@lists.sourceforge.net; Thu, 30 Jun 2005 11:59:11 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42C3DBDC.5050803@bio.ifi.lmu.de>
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

to den 30.06.2005 Klokka 13:47 (+0200) skreiv Frank Steiner:

> Any ideas what could go wrong here?

There is no client side NFS ACL support for NFSv2. Have you tried a
'cat /proc/mounts' to check that the partition is indeed mounted as
NFSv3 when reading the ACLs fails?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
