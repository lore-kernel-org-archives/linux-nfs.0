From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 2] A couple of possible nfs client patches
Date: Tue, 6 Mar 2007 16:40:20 +1100
Message-ID: <20070306163710.8128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOSQg-0000OL-NT
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:41:42 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOSQh-0005Ui-Hu
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:41:44 -0800
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

Hi Trond,
 I wonder if you would consider the following two patches.

The first fixes a real bug that is trivial to demonstrate: script
below.  The problem is that the fattr which is extracted from
READDIRPLUS results does not get a ->time_start set.  This can result
is incorrect attributes being set on files.

The second is really a work-around for a deeper problem (invalidate_inode_pages2
racing with do_no_page) but has value in itself I think.  It extents the combination
 -o nolock,nocto
to avoid flush and invalidate on locking requests.

Thanks,
NeilBrown


 [PATCH 001 of 2] Set meaningful value for fattr->time_start in readdirplus results.
 [PATCH 002 of 2] Avoid flush-when-locking when interclient consistency not needed.

#!/bin/bash
#
# This script will produce the following errormessage from tar
# when run in an NFS mounted directory:
#
#   tar: newdir/innerdir/innerfile: file changed as we read it

# create dirs
rm -rf nfstest
mkdir -p nfstest/dir/innerdir

# create files (should not be empty)
echo "Hello World!" >nfstest/dir/file
echo "Hello World!" >nfstest/dir/innerdir/innerfile

# problem only happens if we sleep before chmod
sleep 1

# change file modes
chmod -R a+r nfstest

# rename dir
mv nfstest/dir nfstest/newdir

# tar it
tar -cf nfstest/nfstest.tar -C nfstest newdir

# restore old dir name
mv nfstest/newdir nfstest/dir


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
