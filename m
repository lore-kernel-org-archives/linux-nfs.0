From: Peter Astrand <peter@cendio.se>
Subject: mounthost option not working
Date: Fri, 19 Mar 2004 10:31:28 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0403191025010.16687-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4GLk-0006Ch-PO
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 01:31:32 -0800
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4GLh-0003Dk-GI
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 01:31:29 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 1E32025DA35
	for <nfs@lists.sourceforge.net>; Fri, 19 Mar 2004 10:31:28 +0100 (CET)
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


The "mounthost" option of the mount command does not work correctly with 
IPs:

# mount -o mounthost=xenocide xenocide:/export/home/pugo /mnt
# umount /mnt
# host xenocide
xenocide.lkpg.cendio.se has address 10.47.255.46
# mount -o mounthost=10.47.255.46 xenocide:/export/home/pugo /mnt
mount: RPC: Remote system error - Network is unreachable

Known problem? The system is Fedora Core 1, with util-linux-2.11y-29.  
Should I submit a bug report at SF and/or RH?


-- 
Peter Åstrand		www.thinlinc.com
Cendio			www.cendio.se
Teknikringen 3		Phone: +46-13-21 46 00
583 30 Linköping





-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
