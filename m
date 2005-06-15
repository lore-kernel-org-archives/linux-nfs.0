From: "M. Todd Smith" <todd@sohovfx.com>
Subject: Re: NFS digest, Vol 1 #2299 - 6 msgs
Date: Wed, 15 Jun 2005 10:37:32 -0400
Message-ID: <42B03D2C.1020803@sohovfx.com>
References: <20050615032704.78BED1373C@sc8-sf-spam2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiZ1S-0007Wh-DF
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 07:37:42 -0700
Received: from smtp0.beanfield.net ([66.207.192.7])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DiZ1P-0003za-OE
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 07:37:42 -0700
Received: from [192.168.1.26] ([66.207.206.227])
	by smtp0.beanfield.net (8.13.4/8.12.11) with ESMTP id j5FEbLRH085564
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 10:37:22 -0400 (EDT)
	(envelope-from todd@sohovfx.com)
To: nfs@lists.sourceforge.net
In-Reply-To: <20050615032704.78BED1373C@sc8-sf-spam2.sourceforge.net>
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

from: Chris Penney <cpenney@gmail.com>

>That seems slow for LSI disks.  I use LSI disk (STK rebrand) and have
>one HBA connected to controller A and the other HBA to controller B.=20
>I then have two 1TB luns primary on A and B (so a total of 4 TB).  I
>get ~300MB/s.  I'm wondering if you are striping across controllers
>and what file system you use (I use JFS).
>
>How are you chaining the luns into one volume?  I use the device
>mapper (4 multipath devices =3D> 1 linear).
>  
>
Chris,

We are using XFS, the spare and parity drives are kept in a seperate 
jbod case w/ seperate controller, so it would seem we are indeed 
striping across controllers (we've had one drive fail so we are using a 
spare in that seperate case now).  We are using two luns and mount them 
seperately as we had some problems with XFS and LVM recognizing volumes 
greater than 2Tb.  Again I didn't set the SAN up .. I'm going to do more 
research in this direction though.

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
