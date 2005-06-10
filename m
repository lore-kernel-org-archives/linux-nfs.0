From: Ryan Sweet <rsweet@aoes.com>
Subject: Re: 2.4 -> 2.6 transition major performance issues
Date: Fri, 10 Jun 2005 13:32:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0506101330330.17693@lapp-0>
References: <20050607143720.GA26081@geggus.net>
Reply-To: Ryan Sweet <rsweet@aoes.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DghkZ-0005tW-O6
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 04:32:35 -0700
Received: from mx0.aoes.nl ([62.58.73.24] helo=ats-mail-0.aoes.nl)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DghkY-0000C7-3q
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 04:32:35 -0700
To: Sven Geggus <sven@geggus.net>
In-Reply-To: <20050607143720.GA26081@geggus.net>
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


> B10 in the FAQ is exactly the Problem I seem to have, but the solutions 
> proposed do net seem to match my case :(
> I neighter have some ancient Kernel (<= 2.4.20) nor do I have a complex
> network setup (just one single switch between the client and the Server 
> machine).

What are your exports (cat /etc/exports on server) and mount (cat /etc/mtab 
on client) settings?

-ryan

-- 
Ryan Sweet             <ryan.sweet@aoes.com>
Advanced Operations and Engineering Services
AOES Group BV            http://www.aoes.com
Phone +31(0)71 5795521  Fax +31(0)71572 1277


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
