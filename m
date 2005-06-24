From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: More Stale NFS handles
Date: Fri, 24 Jun 2005 08:47:11 +0200
Message-ID: <42BBAC6F.7080705@bio.ifi.lmu.de>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>	 <42BB9EA0.3040804@bio.ifi.lmu.de> <1119593709.10716.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Eiwe Lingefors <eiwe@jhu.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dlhy7-0000PR-I4
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 23:47:15 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dlhy7-0003v1-1T
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 23:47:15 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1119593709.10716.6.camel@lade.trondhjem.org>
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

Trond Myklebust wrote

> fr den 24.06.2005 Klokka 07:48 (+0200) skreiv Frank Steiner:
> 
>>There seem to be at least two problem that can cause these. One coming
>>from the server side, maybe journaling related. Read the "Stale File
>>handles keep coming back" thread. The other one is caused by the client
>>and can be fixed by a thread Trond sent on this list. It's also
>>referenced in this thread. This one solved the problem at our site.
> 
> 
> The client patch you are talking about just improves the way we recover
> from ESTALE errors. It does nothing to fix the actual cause of the
> error.

Ok, that's right. But with this patch we don't see any stale NFS
handles anymore, so we are happy for now :-)


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
