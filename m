From: Nick Couchman <nick-lists@seakr.com>
Subject: Re: Root Over NFS Memory Problem
Date: Fri, 05 Mar 2004 06:25:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078493115.13973.3.camel@nick0.seakr.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AzFQs-0002Ax-3a
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 05:32:06 -0800
Received: from gw2.seakr.com ([209.144.181.2] helo=mail-gw.seakr.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AzEzq-0001lv-RN
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 05:04:10 -0800
Received: from scan-gw.seakr.com (seakr5.seakr.com [192.168.100.10])
	by mail-gw.seakr.com (8.12.10/8.12.10) with ESMTP id i25DKg6a007672
	for <nfs@lists.sourceforge.net>; Fri, 5 Mar 2004 06:20:42 -0700
Received: from nick0.seakr.com (nick0 [192.168.10.70])
	by seakr5.seakr.com (8.10.2/8.10.2) with ESMTP id i25DPFZ07481
	for <nfs@lists.sourceforge.net>; Fri, 5 Mar 2004 06:25:16 -0700 (MST)
To: nfs@lists.sourceforge.net
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

> Well, I don't thinkg that its important, we currently mount the 
> nfs-root directory from an initrd and not directly from the kernel >
nfs-root-mount functions. However until 2.4.20 we also used the 
> direct approach and had no problems. Sorry, no further ideas.
>
> Bernd

Looks like it has something to do with OpenMosix, so I'll take this
discussion to that forum.  Thanks!
-- 
Nick Couchman <nick-lists@seakr.com>



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
