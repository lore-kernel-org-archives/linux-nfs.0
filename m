From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: BKL removal from find_exported_dentry()
Date: Tue, 9 Mar 2004 07:54:51 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309135451.GC30766@rx8.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0hnO-000584-Ju
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:01:22 -0800
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0hGg-0006PO-20
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 05:27:34 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id i29Dq85w343598
	for <nfs@lists.sourceforge.net>; Tue, 9 Mar 2004 08:52:08 -0500
Received: from austin.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i29Dq7Zb351560
	for <nfs@lists.sourceforge.net>; Tue, 9 Mar 2004 06:52:08 -0700
Received: from rx8 (jsantos@rx8.austin.ibm.com [9.41.94.101])
	by austin.ibm.com (8.12.10/8.12.10) with ESMTP id i29Dq7vD049174
	for <nfs@lists.sourceforge.net>; Tue, 9 Mar 2004 07:52:07 -0600
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

Hi all

I was running SpecSFS on a 8-way machine when I encounter a situation were 
find_exported_dentry() was showing up to 75% in my profiles.  After some 
digging, the problem was trigger when the system was under memory pressure 
which cause a dramatic shrinkage in dcache entries.  This shrinkage cause the 
code path thats held under the BKL to be hit under a few filesystems (XFS, JFS 
and EXT3).

At first glance, the BKL seem over kill since I don't see it protecting 
anything that not already protected by other locks inside the code path.  I 
went ahead and removed the kernel lock from find_exported_dentry() and after 
several hours of testing different loads and different filesystems I have yet 
to see any kernel badness or
NFS call failures.

Is there anything in particular the BKL is trying to protect here or is it 
safe to remove?

-JRS


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
