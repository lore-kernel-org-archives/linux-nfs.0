From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] intro: make NFSv4 exclusive open calls set and
 use the bitmask in the reply
Date: Tue, 5 Jun 2007 13:56:48 -0400
Message-ID: <20070605135648.579e2557.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvdH8-0008W3-FC
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 10:56:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HvdHA-0003Rt-1m
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 10:57:01 -0700
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

Around a year ago, Chris Lalancette posted a patch to make it so that
when an EXCLUSIVE nfs4 create is done, that the mtime and atime get
properly updated in the following setattr call. At the time Trond
replied that that approach was incorrect and that we need to check the
bitmask in the reply to know what attributes need to be updated.

The original thread is here:

http://linux-nfs.org/pipermail/nfsv4/2006-June/004489.html

The following patchset is a first stab at making the Linux client and
server adhere to the correct NFS4 exclusive open semantics.

As always, comments are appreciated...
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
