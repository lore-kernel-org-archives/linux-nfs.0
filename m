From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: df: Value too large for defined data type
Date: Tue, 06 Jul 2004 09:07:32 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40EA5DC4.5060509@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bhl07-0004Al-3f
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 01:08:27 -0700
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1Bhl05-0000lg-TB
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 01:08:26 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.admin.local (Postfix) with ESMTP id 2535D577A21
	for <nfs@lists.sourceforge.net>; Tue,  6 Jul 2004 09:07:35 +0100 (BST)
Received: from [172.18.10.33] (sys33.prod.local [172.18.10.33])
	by mail.admin.local (Postfix) with ESMTP id 4483E90D923
	for <nfs@lists.sourceforge.net>; Tue,  6 Jul 2004 09:07:33 +0100 (BST)
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

Hi,

Not quite sure is this is an NFS issue or a kernel one, so I thought I'd 
start here.

I'm seeing this error when trying to do a df when I have a large volume 
mounted via NFS (>1573005MB)

df: `/nfs/ps15/mnt/raid1': Value too large for defined data type

The error is occurring on clients running a vanilla 2.6.6 kernel, when 
the server is running a 2.4 kernel.

I've tried 2.4.20 + xfs patches + Trond's NFS_ALL patches, as well as 
vanilla 2.4.25 on the server, with the same results.

When running 2.6.6 on the server there is no problem.

I'm using a SATA RAID with an Infortrend controller, partitioning the 
array on the controller. It's connected to the host via Fibre Channel to 
a qla2300 card.

-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
