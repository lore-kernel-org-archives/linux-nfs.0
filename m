From: Goutham Kurra <kurrag1@yahoo.com>
Subject: force unmount for NFSv3 client
Date: Wed, 11 Aug 2004 11:22:47 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040811182247.81731.qmail@web20527.mail.yahoo.com>
References: <1091461098.3980.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuxkT-0001LL-80
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 11:22:53 -0700
Received: from web20527.mail.yahoo.com ([216.136.227.62])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1BuxkS-0000e9-18
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 11:22:52 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1091461098.3980.22.camel@lade.trondhjem.org>
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


Hi,

I notice some strange problems while trying to unmount
an NFS filesystem after the remote NFS server has died
(while some applications are hung blocked accessing
it)

1. unmount fails with device busy - expected behaviour
2. fuser hangs, so I can't find out which processes
are hung blocked on the mount.
3. umount -f doesn't work - same error device busy.

I've mounted using -intr option. 

Questions:

1. Why does fuser hang?
2. Why do some processes which are hung on that mount
not respond even to SIGKILL (despite the -intr option)
3. Why doesn't force unmount work?

Essentially, under what circumstances is this sort of
behavior likely to happen? I see this very often.

I'm using NFSv3 client on the 2.4.22 kernel with
patches from Trond's 2.4.23-pre-8.


thanks,
goutham



		
__________________________________
Do you Yahoo!?
New and Improved Yahoo! Mail - Send 10MB messages!
http://promotions.yahoo.com/new_mail 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
