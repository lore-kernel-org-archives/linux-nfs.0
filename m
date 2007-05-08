From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: time_after cannot be used alone by NFS code	in
	32bit	architectures
Date: Tue, 08 May 2007 08:34:34 -0400
Message-ID: <1178627674.25317.2.camel@heimdal.trondhjem.org>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
	<17984.5736.617053.65429@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>,
	Ian Kent <raven@themaw.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlOtw-00010G-42
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 05:34:44 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19lkBFh7xLojMvlsClRyk5RNsxnVOPZfkc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlOtx-00011d-Ax
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 05:34:46 -0700
In-Reply-To: <17984.5736.617053.65429@notabene.brown>
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

On Tue, 2007-05-08 at 16:19 +1000, Neil Brown wrote:
> I'm still having trouble picturing the exact failure mode.
> 
> The only one I can see is:
> 
>    Perform a lookup of "foo/bar".
>      Find that it doesn't exist.
>      Create a negative dentry
>    Wait 24 days (jiffie wrap time)
>      During this time the negative dentry
>      is never looked at, and doesn't fall out of cache.
>    Some other access on 'foo' makes sure its
>      change attributes is uptodate
>    Now try to look at foo/bar again.  Due to
>      jiffie wrap, it doesn't seem to be necessary to
>      revalidate, so we don't.
> 
> Having the negative dentry remain in cache for 24 days while untouched
> seems unlikely?

We can pretty trivially fix that scenario. See below.

Trond

------------------------------------------
commit 6d9b786c6c9b5daf8b20927c7495e42e1c7fde6a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon May 7 22:41:18 2007 -0400

    NFS: Fix a jiffie wraparound issue
    
    dentry verifiers are always set to the parent directory's
    cache_change_attribute. There is no reason to be testing for anything other
    than equality when we're trying to find out if the dentry has been checked
    since the last time the directory was modified.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 625d8e5..fced7d1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -650,12 +650,17 @@ int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
  */
 static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 {
+	unsigned long verf;
+
 	if (IS_ROOT(dentry))
 		return 1;
+	verf = (unsigned long)dentry->d_fsdata;
 	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) != 0
-			|| nfs_attribute_timeout(dir))
+			|| nfs_attribute_timeout(dir)
+			|| nfs_caches_unstable(dir)
+			|| verf != NFS_I(dir)->cache_change_attribute)
 		return 0;
-	return nfs_verify_change_attribute(dir, (unsigned long)dentry->d_fsdata);
+	return 1;
 }
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
@@ -665,8 +670,7 @@ static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
 {
-	if (time_after(verf, (unsigned long)dentry->d_fsdata))
-		nfs_set_verifier(dentry, verf);
+	nfs_set_verifier(dentry, verf);
 }
 
 /*



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
