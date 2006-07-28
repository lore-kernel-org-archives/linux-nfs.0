From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH] 2.4 client - update d_cache when server reports
	ENOENT on	an NFS remove
Date: Fri, 28 Jul 2006 16:17:59 -0400
Message-ID: <1154117879.23316.19.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mtosatti@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Ymg-00031D-Ns
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:18:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6Ymd-0008QB-Oc
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:18:09 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6SKI2HB021462
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 16:18:02 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [172.16.52.156])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6SKI2Zs023115
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 16:18:02 -0400
To: nfs@lists.sourceforge.net
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

Anuwat Phrukphicharn of HP discovered and patched this problem in
RHEL-3, and asked that I push it upstream.

When the 2.4 NFS client does a REMOVE and gets an ENOENT back from the
server it does not remove the dentry from the d_cache. This can make it
inappropriately keep writing to an inode that has been renamed.

To reproduce, run this on an NFS server with /scratch exported:

#!/bin/sh
dir=/scratch/98201
mkdir -p $dir/recv
cat /dev/null > $dir/recv/x
while true; do
        length=`wc -l $dir/recv/x | cut -d' ' -f1`
        if [ ${length} -gt 1 ]; then
                echo "problem occured!"
                date
                exit 1
        fi
        mv $dir/x $dir/recv/x
        sleep 1
done


...and then do this on the client:

mount server:/scratch /mnt/server
while true; do
        rm -f /mnt/server/98201/x
        date >> /mnt/server/98201/x
        usleep 100
done

The file "x" should never contain more than 1 line, but occasionally,
the server will report an ENOENT back to the client (indicating that the
server script has renamed the file before the rm could occur). After
this, the client will keep appending to the same inode, even though the
file has been renamed.

I've not seen this problem in 2.6 kernels, but I've not done any
extensive testing there as of yet so I can't confirm whether it's still
a problem there or not.

A patch to fix this follows. It just makes ENOENT a special case when
handling errors in the nfs_safe_remove function, and lets the client
update the dcache as if the remove had succeeded. The ENOENT is still
reported back to userspace. This corrected the problem on my test rig
and for the reporter as well:

--- linux-2.4.21/fs/nfs/dir.c.unlink-enoent
+++ linux-2.4.21/fs/nfs/dir.c
@@ -1023,7 +1023,10 @@ static int nfs_safe_remove(struct dentry
 	if (inode)
 		NFS_CACHEINV(inode);
 	error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
-	if (error < 0)
+
+	/* if server returned ENOENT, assume that the dentry is already gone
+	 * and update the cache accordingly */
+	if (error < 0 && (error != -ENOENT))
 		goto out;
 	if (inode)
 		inode->i_nlink--;



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
