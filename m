From: Neil Brown <neilb@suse.de>
Subject: NFS directory caching problem - with test case and patch.
Date: Mon, 26 Feb 2007 12:48:25 +1100
Message-ID: <17890.15465.343426.519809@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLUzS-0002PU-IA
	for nfs@lists.sourceforge.net; Sun, 25 Feb 2007 17:49:22 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HLUzU-0002fE-5V
	for nfs@lists.sourceforge.net; Sun, 25 Feb 2007 17:49:24 -0800
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


Try running this script in an NFS mounted directory (Client relatively
recent - 2.6.18 has the problem as does 2.6.20).

------------------------------------------------------
#!/bin/bash
#
# This script will produce the following errormessage from tar:
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
--------------------------------------------------------

What happens:

The 'chmod -R' does a readdir_plus in each directory and the results
get cached in the page cache.  It then updates the ctime on each file
by one second.  When this happens, the post-op attributes are used to
update the ctime stored on the client to match the value in the kernel.

The 'mv' calls shrink_dcache_parent on the directory tree which
flushes all the dentries (so a new lookup will be required) but
doesn't flush the inodes or pagecache.

The 'tar' does a readdir on each directory, but (in the case of
'innerdir' at least) satisfies it from the pagecache and uses the
READDIRPLUS data to update all the inodes.  In the case of
'innerdir/innerfile', the ctime is out of date.

'tar' then calls 'lstat' on innerdir/innerfile getting an old ctime.
It then opens the file (triggering a GETATTR), reads the content, and
then calls fstat to see if anything has changed.  It finds that ctime
has changed and so complains.

The problem seems to be that the cache readdirplus info is kept around
for too long.

My patch below discards pagecache data for directories when
dentry_iput is called on them.  This effectively removes the symptom
which convinces me that I correctly understand the problem.  However
I'm not convinced that is a proper solution, as there could easily be
other races that trigger the same problem without being affected by
this 'fix'.

One possibility would be to require that readdirplus pagecache data be
only used *once* to instantiate an inode.  Somehow it should then be
invalidated so that if the dentry subsequently disappears, it will
cause a new request to the server to fill in the stat data.

Another possibility is to compare the cache_change_attribute on the
inode with something similar for the readdirplus info and reject the
info from readdirplus if it is too old.

I haven't tried to implement these and would value other opinions
before I do.

Thanks,
NeilBrown


Signed-off-by: Neil Brown <neilb@suse.de>

diff .prev/fs/nfs/dir.c ./fs/nfs/dir.c
--- .prev/fs/nfs/dir.c	2007-02-26 12:08:29.000000000 +1100
+++ ./fs/nfs/dir.c	2007-02-26 12:44:33.000000000 +1100
@@ -843,6 +843,10 @@ static int nfs_dentry_delete(struct dent
 static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 {
 	nfs_inode_return_delegation(inode);
+	if (S_ISDIR(inode->i_mode))
+		/* drop any readdir cache as it could easily be old */
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
+
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		lock_kernel();
 		drop_nlink(inode);


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
