From: Sten Spans <sten@blinkenlights.nl>
Subject: Re: Performance Difference Between Linux NFS Server and Netapp
Date: Thu, 14 Jul 2005 13:25:13 +0200 (CEST)
Message-ID: <Pine.SOC.4.61.0507141312090.9294@tea.blinkenlights.nl>
References: <42D2F8F9.4010304@plasmabat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt1qG-0002xf-Mr
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 04:25:24 -0700
Received: from ford.blinkenlights.nl ([213.204.211.2] ident=sten)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt1qF-0001YR-6L
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 04:25:24 -0700
To: Hugh Caley <hcaley@plasmabat.com>
In-Reply-To: <42D2F8F9.4010304@plasmabat.com>
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

On Mon, 11 Jul 2005, Hugh Caley wrote:

> How does Netapp do it?  Don't suppose they'd tell me ...

Quite simple really, you pay them loads of money, they
give part of it to engineers doing work on nfs tuning.

They generally have 3 performance advantages:

- battery backed cache with full os support,
   which should make it perform better than battery backed
   cache on normal raid cards. They use this cache for
   journaling. I suppose one could try something similar
   with pci-ram cards with battery and store the journal
   on these.

- special filesystem which allows writing data on any
   disk, this allows distributing the workload across the
   available disks, more disks more performance
   ( if the fibrechannel can handle it ).

- Highly tuned nfs inplementation with dedicated operating system.

The bruteforce linux approach is quite good for the money spent,
but don't expect the features/performance of a way more expensive
enterprise solution.

-- 
Sten Spans

"There is a crack in everything, that's how the light gets in."
Leonard Cohen - Anthem


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
