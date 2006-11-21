From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][0/2] NFS: Calculate 'w' a bit later in
	*_encode_getaclres()
Date: Tue, 21 Nov 2006 12:33:59 +0100
Message-ID: <200611211234.00251.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	David Rientjes <rientjes@cs.washington.edu>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmTtH-0004gT-7P
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:15 -0800
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmTtG-0001xz-2z
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 03:34:16 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1430751ugc
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 03:34:09 -0800 (PST)
To: LKML <linux-kernel@vger.kernel.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Here are two patches that implement a tiny performance improvement for NFS.

The change made is to calculate the value of the 'w' variable a little 
later than is currently done. This way we don't waste time calculating 'w' 
in the cases where we return from the function before using the calculated 
value.  It also saves a few bytes of .text, which is always nice.

The last time around these got merged in -mm and subsequently dropped - 
according to akpm, they got dropped due to maintainer NACK, but my 
impression was that this change was OK.  So, this time around It would be 
great with an explicit ACK or NACK so akpm can add the patches or ignore 
them.

The two patches are send with the following subjects to the same recipients
as this mail:

  [PATCH][1/2] NFS2: Calculate 'w' a bit later in nfsaclsvc_encode_getaclres()
  [PATCH][2/2] NFS3: Calculate 'w' a bit later in nfs3svc_encode_getaclres()


Kind regards,

  Jesper Juhl <jesper.juhl@gmail.com>


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
