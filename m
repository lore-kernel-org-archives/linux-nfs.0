From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Access cache forgetting mode bits
Date: Sun, 31 Aug 2003 23:22:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F52BB88.2040303@RedHat.com>
References: <3F4E302F.5060409@RedHat.com>	 <1062107512.2121.25.camel@bree.suse.de>  <3F525BA8.9020904@RedHat.com> <1062372316.2341.16.camel@bree.suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030105030501000007060101"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
   Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19tfHz-0000qp-00
	for <nfs@lists.sourceforge.net>; Sun, 31 Aug 2003 20:23:35 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19tfHx-0001KN-T7
	for nfs@lists.sourceforge.net; Sun, 31 Aug 2003 20:23:34 -0700
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <1062372316.2341.16.camel@bree.suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------030105030501000007060101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andreas Gruenbacher wrote:

>On Sun, 2003-08-31 at 22:33, Steve Dickson wrote:
>  
>
>>
>>I'm thinking there might even be a better way to cache these bits...
>>
>>It seems the OS calls nfs_permission() to test each permission
>>    
>>
>
>Individually you mean? That's not at all the case in general.
>
Yes...  So at times there will be more than one bit set in the mask?
I know that's how it works in other OS but I was not sure with linux...

>>what if on the first access call, we get *all* of the access bits 
>>from the
>>server and cache them locally (i.e. in cache->mask). That way when 
>>nfs_permission()
>>is called again, all if the needed info is there... The attached patch 
>>does just that
>>and it really seems to cut down on the amount access rpc needed...
>>
>>Thoughts?
>>    
>>
>
>You have again attached your first, buggy patch.
>  
>
Oops... I hate when that happens....

SteveD.


--------------030105030501000007060101
Content-Type: text/plain;
 name="linux-2.4.21-nfs-accesscache.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-accesscache.patch"

--- linux-2.4.21/fs/nfs/dir.c.orig	2003-08-31 13:04:30.000000000 -0400
+++ linux-2.4.21/fs/nfs/dir.c	2003-08-31 13:07:49.000000000 -0400
@@ -1259,17 +1259,21 @@ nfs_permission(struct inode *inode, int 
 
 	if ((server->flags & NFS_MOUNT_NOACL) || !NFS_PROTO(inode)->access)
 		goto out_notsup;
+	/*
+	 * See if we can use the cache
+	 */
 	cred = rpcauth_lookupcred(NFS_CLIENT(inode)->cl_auth, 0);
 	if (cache->cred == cred
 	    && time_before(jiffies, cache->jiffies + NFS_ATTRTIMEO(inode))) {
-		if (!cache->err) {
-			/* Is the mask a subset of an accepted mask? */
-			if ((cache->mask & mask) == mask)
-				goto out_cached;
-	       	} else {
-			/* ...or is it a superset of a rejected mask? */
-			if ((cache->mask & mask) == cache->mask)
-				goto out_cached;
+		/* Is the mask a subset of an accepted mask? */
+		if ((cache->mask & mask) == mask) {
+			cache->err  = 0;
+			goto out_cached;
+		} 
+		/* ...or is it a superset of a rejected mask? */
+		if ((~cache->mask & mask) == mask) {
+			cache->err  = -EACCES;
+			goto out_cached;
 		}
 	}
 	error = NFS_PROTO(inode)->access(inode, cred, mask);
@@ -1278,8 +1282,6 @@ nfs_permission(struct inode *inode, int 
 		if (cache->cred)
 			put_rpccred(cache->cred);
 		cache->cred = cred;
-		cache->mask = mask;
-		cache->err = error;
 		return error;
 	}
 	put_rpccred(cred);
--- linux-2.4.21/fs/nfs/nfs3proc.c.orig	2003-08-30 16:30:57.000000000 -0400
+++ linux-2.4.21/fs/nfs/nfs3proc.c	2003-08-31 12:58:11.000000000 -0400
@@ -121,10 +121,13 @@ static int
 nfs3_proc_access(struct inode *inode, struct rpc_cred *cred, int mode)
 {
 	struct nfs_fattr	fattr;
+	struct nfs_access_cache *cache = &NFS_I(inode)->cache_access;
 	struct nfs3_accessargs	arg = { NFS_FH(inode), 0 };
 	struct nfs3_accessres	res = { &fattr, 0 };
 	struct rpc_message msg = { NFS3PROC_ACCESS, &arg, &res, cred };
 	int	status;
+	static int may_write, may_exec;
+	__u32 access;
 
 	dprintk("NFS call  access\n");
 	fattr.valid = 0;
@@ -134,20 +137,45 @@ nfs3_proc_access(struct inode *inode, st
 	if (S_ISDIR(inode->i_mode)) {
 		if (mode & MAY_WRITE)
 			arg.access |= NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND | NFS3_ACCESS_DELETE;
+		may_write = NFS3_ACCESS_MODIFY| NFS3_ACCESS_EXTEND | NFS3_ACCESS_DELETE;
+
 		if (mode & MAY_EXEC)
 			arg.access |= NFS3_ACCESS_LOOKUP;
+		may_exec = NFS3_ACCESS_LOOKUP;
+
 	} else {
 		if (mode & MAY_WRITE)
 			arg.access |= NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND;
+		may_write = NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND;
+
 		if (mode & MAY_EXEC)
 			arg.access |= NFS3_ACCESS_EXECUTE;
+		may_exec = NFS3_ACCESS_EXECUTE;
 	}
+	/*
+	 * Save off whats needed and then ask for all of the mode bits
+	 * which will be cached
+	 */
+	access = arg.access;
+	arg.access = (NFS3_ACCESS_EXECUTE|NFS3_ACCESS_READ|NFS3_ACCESS_MODIFY| 
+		NFS3_ACCESS_EXTEND|NFS3_ACCESS_DELETE|NFS3_ACCESS_LOOKUP);
+
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	nfs_refresh_inode(inode, &fattr);
 	dprintk("NFS reply access\n");
 
-	if (status == 0 && (arg.access & res.access) != arg.access)
+	if (status == 0 && (access & res.access) != access)
 		status = -EACCES;
+
+	if ((!status || status == -EACCES)) {
+		cache->mask = 0;
+		if (res.access & NFS3_ACCESS_READ)
+			cache->mask |= MAY_READ;
+		if (res.access & may_write)
+			cache->mask |= MAY_WRITE;
+		if (res.access & may_exec)
+			cache->mask |= MAY_EXEC;
+	}
 	return status;
 }
 

--------------030105030501000007060101--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
