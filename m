From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/10] knfsd: RMDA Transport Driver v2
Date: Sun, 01 Jul 2007 18:02:58 -0500
Message-ID: <20070701230258.29354.89949.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I58ae-000365-Uh
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:25 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I58ai-0007c9-9o
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 16:12:28 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id E4F477C758
	for <nfs@lists.sourceforge.net>; Sun,  1 Jul 2007 18:12:23 -0500 (CDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patchset implements the NFS-RDMA transport driver for RDMA. It is 
a follow-up to the earlier patchset and reflects recommendations by 
various reviewers.  Most notable improvements are as follows:

- Moved all WR processing into a tasklet reducing the number of irqsave
  locks to 1. 

- Added support for RDMA_READ completion processing that avoids wait
  in an NFSD thread. 

- Integration with the transport switch patchset changes from SGI

- Support for dynamically adding listeners via writes to the portlist file

I looked at making the context allocation fixed. This would require 161 
pages of contexts for 32k wsize/rsize and the default RQ and SQ depths. 
Big data would drive this number up to 5152 pages. This seemed 
untenable to me. Maybe a pool shared across all mounts?

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
