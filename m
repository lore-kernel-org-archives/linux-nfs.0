From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: More Stale NFS handles
Date: Fri, 24 Jun 2005 07:48:16 +0200
Message-ID: <42BB9EA0.3040804@bio.ifi.lmu.de>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dlh38-00062U-I5
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 22:48:22 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Dlh37-0004pR-1t
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 22:48:22 -0700
To: Eiwe Lingefors <eiwe@jhu.edu>
In-Reply-To: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
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

Eiwe Lingefors wrote

> I have trawled the nfs mailing list archives a bit and judging by  
> recent posts there is undoubtedly several others with the same  
> problem.   The problems started happening when I installed a new  
> Fedora Core 3 server and migrated home directories to it. Like Jim  
> Farley mentioned in a recent thread on the list, our environment has  
> been stable for years prior.

There seem to be at least two problem that can cause these. One coming
from the server side, maybe journaling related. Read the "Stale File
handles keep coming back" thread. The other one is caused by the client
and can be fixed by a thread Trond sent on this list. It's also
referenced in this thread. This one solved the problem at our site.

cu,
Frank


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
