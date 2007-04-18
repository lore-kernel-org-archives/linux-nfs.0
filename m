From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] RFC: NFSv4 in-kernel mount option parsing
Date: Wed, 18 Apr 2007 13:07:52 -0400
Message-ID: <20070418170631.11696.93281.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeDdZ-0007Tq-Hg
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 10:08:10 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeDda-0001sY-Vl
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 10:08:12 -0700
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

Following is a series of three patches that add support for parsing NFSv4
mount options in the kernel instead of in user-space.  The mount options are
passed as a string, similar to other Linux file systems such as ext3.

I've done NFSv4 first because it doesn't require changes to the in-kernel
mount client.  Plans are to follow up with NFSv2/3 support soon.

Some testing has been done on previous versions of these patches, but the only
testing done on these three has been compile testing.

Please review and comment.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
