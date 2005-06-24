From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: More Stale NFS handles
Date: Fri, 24 Jun 2005 02:15:09 -0400
Message-ID: <1119593709.10716.6.camel@lade.trondhjem.org>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
	 <42BB9EA0.3040804@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eiwe Lingefors <eiwe@jhu.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DlhUT-0007Pw-P7
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 23:16:37 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DlhUS-00081Y-8R
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 23:16:37 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42BB9EA0.3040804@bio.ifi.lmu.de>
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

fr den 24.06.2005 Klokka 07:48 (+0200) skreiv Frank Steiner:

> There seem to be at least two problem that can cause these. One coming
> from the server side, maybe journaling related. Read the "Stale File
> handles keep coming back" thread. The other one is caused by the client
> and can be fixed by a thread Trond sent on this list. It's also
> referenced in this thread. This one solved the problem at our site.


The client patch you are talking about just improves the way we recover
from ESTALE errors. It does nothing to fix the actual cause of the
error.

The most common actual causes of ESTALE are listed on 

          http://nfs.sourceforge.net/#faq_a10

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
