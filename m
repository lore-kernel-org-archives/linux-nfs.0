From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Wrong file size (large file problem)
Date: Fri, 13 Feb 2004 11:52:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040213165242.GC27903@fieldses.org>
References: <Pine.LNX.4.44.0402131420000.13346-100000@kakadu.cosy.sbg.ac.at> <200402131717.34182.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerald Stieglbauer <gstiegl@cosy.sbg.ac.at>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArgaY-0007Pn-Ot
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:54:50 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ArgVh-0002RB-9p
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 08:49:49 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200402131717.34182.vincent.roqueta@ext.bull.net>
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

On Fri, Feb 13, 2004 at 05:17:34PM +0100, Vincent ROQUETA wrote:
> Well... In my bug, the size of the big file is not  4294967294, that is the 
> ... user name and group name (Really stranges too... !!! )


4294967294 == 2^32 - 2 == (uint32_t)(-2).  Do a grep for -2 in
fs/nfsd/*.c, and you'll see where that number's coming from.

Nothing to do with the file sizes, in any case.

--Bruce Fields


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
