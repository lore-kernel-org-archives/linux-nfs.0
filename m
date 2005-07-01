From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Strange problem with ACL over NFS
Date: Fri, 01 Jul 2005 17:03:11 +0200
Message-ID: <42C55B2F.4060301@bio.ifi.lmu.de>
References: <42C3DBDC.5050803@bio.ifi.lmu.de> <1120157929.8922.14.camel@lade.trondhjem.org> <42C4DA08.8070202@bio.ifi.lmu.de> <20050701134307.GC13619@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DoN2y-0005Tt-24
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 08:03:16 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DoN2v-0006tP-HQ
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 08:03:15 -0700
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050701134307.GC13619@hmsendeavour.rdu.redhat.com>
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

Neil Horman wrote

> Just out of curiosity what kind of file system are the NFS servers export to
> NFS?  Is it a shared cluster fs, like vxfs, or ocfs, or the like, or is it just
> plain old ext3?
> Neil

Plain old reiserfs :-)


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
