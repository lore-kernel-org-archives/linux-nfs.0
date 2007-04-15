From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 001 of 2] Set meaningful value for
	fattr->time_start in	readdirplus results.
Date: Mon, 16 Apr 2007 09:35:27 +1000
Message-ID: <17954.46783.532806.874084@notabene.brown>
References: <20070306163710.8128.patches@notabene> <1070306054025.8345@suse.de>
	<1176588819.6089.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdEG3-0004g2-15
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 16:35:47 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdEG5-0004jJ-1C
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 16:35:49 -0700
In-Reply-To: message from Trond Myklebust on Saturday April 14
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

On Saturday April 14, trond.myklebust@fys.uio.no wrote:
> 
> Hmm... NACK on this one. If page->index != 0, or if we're reading a
> cached page then desc->timestamp is uninitialised.

Well... not completely uninitialised.  The 'memset' in nfs_readdir
sets it to zero, but that isn't really helpful.

Yes, the patch is broken as it stands.

> 
> One solution might be to detect if find_dirent_page called
> nfs_readdir_filler, and then to have dir_decode() set NFS_ATTR_FATTR
> only if we're reading a fresh page?

That probably works well enough.  If the app is doing very small
getdirents call, the first few entries from each page will have the
readdir_plus info honoured and the remainder will have it ignored.  I
doubt that is a problem in real-life.... unless it means the d_type
field doesn't get set properly.

Anyway, here is an updated patch that uses the above idea and has been
tested to solve the particular symptom.

Thanks,
NeilBrown


Don't use uninitialsed value for fattr->time_start in readdirplus results.

The 'fattr' structure filled in by nfs3_decode_direct does not get a
value for ->time_start set.
Thus if an entry is for an inode that we already have in cache,
when nfs_readdir_lookup calls nfs_fhget, it will call nfs_refresh_inode
and may update the inode with out-of-date information.

Directories are read a page at a time, so each page could have a
different timestamp that "should" be used to set the time_start for
the fattr for info in that page.  However storing the timestamp per
page is awkward.  (We could stick in the first 4 bytes and only read 4092
bytes, but that is a bigger code change than I am interested it).

This patch ignores the readdir_plus attributes if a readdir finds the
information already in cache, and otherwise sets ->time_start to the time
the readdir request was sent to the server.

It might be nice to store - in the directory inode - the time stamp for
the earliest readdir request that is still in the page cache, so that we
don't ignore attribute data that we don't have to.  This patch doesn't do
that.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfs/dir.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff .prev/fs/nfs/dir.c ./fs/nfs/dir.c
--- .prev/fs/nfs/dir.c	2007-04-16 09:15:12.000000000 +1000
+++ ./fs/nfs/dir.c	2007-04-16 09:30:30.000000000 +1000
@@ -153,6 +153,8 @@ typedef struct {
 	decode_dirent_t	decode;
 	int		plus;
 	int		error;
+	unsigned long	timestamp;
+	int		timestamp_valid;
 } nfs_readdir_descriptor_t;
 
 /* Now we cache directories properly, by stuffing the dirent
@@ -194,6 +196,8 @@ int nfs_readdir_filler(nfs_readdir_descr
 		}
 		goto error;
 	}
+	desc->timestamp = timestamp;
+	desc->timestamp_valid = 1;
 	SetPageUptodate(page);
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATIME;
@@ -224,6 +228,10 @@ int dir_decode(nfs_readdir_descriptor_t 
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 	desc->ptr = p;
+	if (desc->timestamp_valid)
+		desc->entry->fattr->time_start = desc->timestamp;
+	else
+		desc->entry->fattr->valid &= ~NFS_ATTR_FATTR;
 	return 0;
 }
 
@@ -315,6 +323,10 @@ int find_dirent_page(nfs_readdir_descrip
 			__FUNCTION__, desc->page_index,
 			(long long) *desc->dir_cookie);
 
+	/* If we find the page in the page_cache, we cannot be sure
+	 * how fresh the data is, so we will ignore readdir_plus attributes.
+	 */
+	desc->timestamp_valid = 0;
 	page = read_cache_page(inode->i_mapping, desc->page_index,
 			       (filler_t *)nfs_readdir_filler, desc);
 	if (IS_ERR(page)) {
@@ -462,6 +474,7 @@ int uncached_readdir(nfs_readdir_descrip
 	struct rpc_cred	*cred = nfs_file_cred(file);
 	struct page	*page = NULL;
 	int		status;
+	unsigned long	timestamp;
 
 	dfprintk(DIRCACHE, "NFS: uncached_readdir() searching for cookie %Lu\n",
 			(unsigned long long)*desc->dir_cookie);
@@ -471,6 +484,7 @@ int uncached_readdir(nfs_readdir_descrip
 		status = -ENOMEM;
 		goto out;
 	}
+	timestamp = jiffies;
 	desc->error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, *desc->dir_cookie,
 						page,
 						NFS_SERVER(inode)->dtsize,
@@ -481,6 +495,8 @@ int uncached_readdir(nfs_readdir_descrip
 	desc->page = page;
 	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
 	if (desc->error >= 0) {
+		desc->timestamp = timestamp;
+		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
 			desc->entry->prev_cookie = *desc->dir_cookie;
 	} else

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
