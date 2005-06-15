From: "M. Todd Smith" <todd@sohovfx.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 10:47:26 -0400
Message-ID: <42B03F7E.8090206@sohovfx.com>
References: <EXCHG2003LVbNDN4Cxp000005b6@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiZAy-00087c-Iz
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 07:47:32 -0700
Received: from smtp0.beanfield.net ([66.207.192.7])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DiZAy-000616-21
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 07:47:32 -0700
Received: from [192.168.1.26] ([66.207.206.227])
	by smtp0.beanfield.net (8.13.4/8.12.11) with ESMTP id j5FElFYL086128
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 10:47:15 -0400 (EDT)
	(envelope-from todd@sohovfx.com)
To: nfs@lists.sourceforge.net
In-Reply-To: <EXCHG2003LVbNDN4Cxp000005b6@EXCHG2003.microtech-ks.com>
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

Roger Heflin wrote:

>Are you using the same dd test on the local machine test?  If so
>cache will be a major factor.
>
>Also, raid5 stripe size, bigger is almost always better, I would
>do some testing with different strip sizes and see how it affects
>the speed, I have never seen less than 32k be faster than 32k.
>
>Are you using md for the raid5 setup or something else that has
>not been mentioned?
>
>                     Roger 
>  
>
Roger,

I was told by a consultant we hired to help us with this that 5Gb test 
files should be large enough to blow out the caches.  Looking back I 
realize that must have been when we only had 2Gb RAM in the machine .. 
is there a better test I can use to check local rw performance, as well 
is there a formula or recommended way to calculate how big a file you 
should rw to properly check local rw?

I'll have to ask our soft eng who worked with the consultant as to why 
that particular stripe size was used.  I believe we are using md, we 
attempted to use LVM but ran into some problems and had some file 
inconsistencies that were unacceptable so had to back out of it.

Cheers
Todd

-- 
Systems Administrator
----------------------------------
Soho VFX - Visual Effects Studio
99 Atlantic Avenue, Suite 303
Toronto, Ontario, M6K 3J8
(416) 516-7863 
http://www.sohovfx.com
----------------------------------


 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
