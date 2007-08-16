From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Thu, 16 Aug 2007 12:10:07 -0400
Message-ID: <46C476DF.3070607@redhat.com>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080306000308010704060800"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILhvQ-000431-7I
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 09:10:20 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILhvT-0003Ma-Mz
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 09:10:24 -0700
In-Reply-To: <20070804223256.GA1155@fieldses.org>
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

This is a multi-part message in MIME format.
--------------080306000308010704060800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Fri, Aug 03, 2007 at 03:29:10PM -0400, Peter Staubach wrote:
>   
>> Hi.
>>
>> Attached is a patch to modify the NFS server code to support
>> 64 bit ino's, as appropriate for the system and the NFS
>> protocol version.
>>
>> The gist of the changes is to query the underlying file system
>> for attributes and not just to use the cached attributes in the
>> inode.  For this specific purpose, the inode only contains an
>> ino field which unsigned long, which is large enough on 64 bit
>> platforms, but is not large enough on 32 bit platforms.
>>     
>
> Thanks!
>
>   
>> @@ -203,31 +203,15 @@ encode_fattr3(struct svc_rqst *rqstp, __
>>  static __be32 *
>>  encode_saved_post_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
>>  {
>> -	struct inode	*inode = fhp->fh_dentry->d_inode;
>> +	if (!fhp->fh_post_saved) {
>> +		*p++ = xdr_zero;
>> +		return p;
>> +	}
>>     
>
> The caller, encode_wcc_data(), already did this check.
>
>   
>>  	/* Attributes to follow */
>>  	*p++ = xdr_one;
>>  
>> -	*p++ = htonl(nfs3_ftypes[(fhp->fh_post_mode & S_IFMT) >> 12]);
>> -	*p++ = htonl((u32) fhp->fh_post_mode);
>> -	*p++ = htonl((u32) fhp->fh_post_nlink);
>> -	*p++ = htonl((u32) nfsd_ruid(rqstp, fhp->fh_post_uid));
>> -	*p++ = htonl((u32) nfsd_rgid(rqstp, fhp->fh_post_gid));
>> -	if (S_ISLNK(fhp->fh_post_mode) && fhp->fh_post_size > NFS3_MAXPATHLEN) {
>> -		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
>> -	} else {
>> -		p = xdr_encode_hyper(p, (u64) fhp->fh_post_size);
>> -	}
>> -	p = xdr_encode_hyper(p, ((u64)fhp->fh_post_blocks) << 9);
>> -	*p++ = fhp->fh_post_rdev[0];
>> -	*p++ = fhp->fh_post_rdev[1];
>> -	p = encode_fsid(p, fhp);
>> -	p = xdr_encode_hyper(p, (u64) inode->i_ino);
>> -	p = encode_time3(p, &fhp->fh_post_atime);
>> -	p = encode_time3(p, &fhp->fh_post_mtime);
>> -	p = encode_time3(p, &fhp->fh_post_ctime);
>> -
>> -	return p;
>> +	return encode_fattr3(rqstp, p, fhp, &fhp->fh_post_attr);
>>     
>
> Is there a problem with the lease_get_mtime() call in encode_fattr3()?
> It looks like that could return the current time rather than the time
> that was supposedly atomic with respect to the operation.
>
> Dumb question: I assume it's always legal to call ->getattr while
> holding the i_mutex?

Hi.

Attached is a new patch which should address the issues raised
by Bruce.

I haven't been able to find any reason why ->getattr can't be called
while i_mutex.  The specification indicates that i_mutex is not
required to be held in order to invoke ->getattr, but it doesn't say
that i_mutex can't be held while invoking ->getattr.

I also haven't come to any conclusions regarding the value of
lease_get_mtime() and whether it should or should not be invoked
by fill_post_wcc() too.  I chose not to change this because I
thought that it was safer to leave well enough alone.  If we
decide to make a change, it can be done separately.

So, here we go again -- :-)

---

Attached is a patch to modify the NFS server code to support
64 bit ino's, as appropriate for the system and the NFS
protocol version.

The gist of the changes is to query the underlying file system
for attributes and not just to use the cached attributes in the
inode.  For this specific purpose, the inode only contains an
ino field which unsigned long, which is large enough on 64 bit
platforms, but is not large enough on 32 bit platforms.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>





--------------080306000308010704060800
Content-Type: text/plain;
 name="fc-6.ino64.server.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fc-6.ino64.server.2"

--- linux-2.6.22.i686/fs/nfsd/nfs3xdr.c.org
+++ linux-2.6.22.i686/fs/nfsd/nfs3xdr.c
@@ -174,9 +174,6 @@ static __be32 *
 encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	      struct kstat *stat)
 {
-	struct dentry	*dentry = fhp->fh_dentry;
-	struct timespec time;
-
 	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
 	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
@@ -191,10 +188,9 @@ encode_fattr3(struct svc_rqst *rqstp, __
 	*p++ = htonl((u32) MAJOR(stat->rdev));
 	*p++ = htonl((u32) MINOR(stat->rdev));
 	p = encode_fsid(p, fhp);
-	p = xdr_encode_hyper(p, (u64) stat->ino);
+	p = xdr_encode_hyper(p, stat->ino);
 	p = encode_time3(p, &stat->atime);
-	lease_get_mtime(dentry->d_inode, &time); 
-	p = encode_time3(p, &time);
+	p = encode_time3(p, &stat->mtime);
 	p = encode_time3(p, &stat->ctime);
 
 	return p;
@@ -203,31 +199,9 @@ encode_fattr3(struct svc_rqst *rqstp, __
 static __be32 *
 encode_saved_post_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
-	struct inode	*inode = fhp->fh_dentry->d_inode;
-
 	/* Attributes to follow */
 	*p++ = xdr_one;
-
-	*p++ = htonl(nfs3_ftypes[(fhp->fh_post_mode & S_IFMT) >> 12]);
-	*p++ = htonl((u32) fhp->fh_post_mode);
-	*p++ = htonl((u32) fhp->fh_post_nlink);
-	*p++ = htonl((u32) nfsd_ruid(rqstp, fhp->fh_post_uid));
-	*p++ = htonl((u32) nfsd_rgid(rqstp, fhp->fh_post_gid));
-	if (S_ISLNK(fhp->fh_post_mode) && fhp->fh_post_size > NFS3_MAXPATHLEN) {
-		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
-	} else {
-		p = xdr_encode_hyper(p, (u64) fhp->fh_post_size);
-	}
-	p = xdr_encode_hyper(p, ((u64)fhp->fh_post_blocks) << 9);
-	*p++ = fhp->fh_post_rdev[0];
-	*p++ = fhp->fh_post_rdev[1];
-	p = encode_fsid(p, fhp);
-	p = xdr_encode_hyper(p, (u64) inode->i_ino);
-	p = encode_time3(p, &fhp->fh_post_atime);
-	p = encode_time3(p, &fhp->fh_post_mtime);
-	p = encode_time3(p, &fhp->fh_post_ctime);
-
-	return p;
+	return encode_fattr3(rqstp, p, fhp, &fhp->fh_post_attr);
 }
 
 /*
@@ -246,6 +220,7 @@ encode_post_op_attr(struct svc_rqst *rqs
 		err = vfs_getattr(fhp->fh_export->ex_mnt, dentry, &stat);
 		if (!err) {
 			*p++ = xdr_one;		/* attributes follow */
+			lease_get_mtime(dentry->d_inode, &stat.mtime); 
 			return encode_fattr3(rqstp, p, fhp, &stat);
 		}
 	}
@@ -284,6 +259,23 @@ encode_wcc_data(struct svc_rqst *rqstp, 
 	return encode_post_op_attr(rqstp, p, fhp);
 }
 
+/*
+ * Fill in the post_op attr for the wcc data
+ */
+void fill_post_wcc(struct svc_fh *fhp)
+{
+	int err;
+
+	if (fhp->fh_post_saved)
+		printk("nfsd: inode locked twice during operation.\n");
+
+	err = vfs_getattr(fhp->fh_export->ex_mnt, fhp->fh_dentry,
+			&fhp->fh_post_attr);
+	if (err)
+		fhp->fh_post_saved = 0;
+	else
+		fhp->fh_post_saved = 1;
+}
 
 /*
  * XDR decode functions
@@ -643,8 +635,11 @@ int
 nfs3svc_encode_attrstat(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_attrstat *resp)
 {
-	if (resp->status == 0)
+	if (resp->status == 0) {
+		lease_get_mtime(resp->fh.fh_dentry->d_inode,
+				&resp->stat.mtime); 
 		p = encode_fattr3(rqstp, p, &resp->fh, &resp->stat);
+	}
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -802,7 +797,7 @@ nfs3svc_encode_readdirres(struct svc_rqs
 
 static __be32 *
 encode_entry_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name,
-	     int namlen, ino_t ino)
+	     int namlen, u64 ino)
 {
 	*p++ = xdr_one;				 /* mark entry present */
 	p    = xdr_encode_hyper(p, ino);	 /* file id */
@@ -873,7 +868,7 @@ compose_entry_fh(struct nfsd3_readdirres
 #define NFS3_ENTRYPLUS_BAGGAGE	(1 + 21 + 1 + (NFS3_FHSIZE >> 2))
 static int
 encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
-	     loff_t offset, ino_t ino, unsigned int d_type, int plus)
+	     loff_t offset, u64 ino, unsigned int d_type, int plus)
 {
 	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres,
 		       					common);
--- linux-2.6.22.i686/fs/nfsd/nfsxdr.c.org
+++ linux-2.6.22.i686/fs/nfsd/nfsxdr.c
@@ -523,6 +523,10 @@ nfssvc_encode_entry(void *ccdv, const ch
 		cd->common.err = nfserr_toosmall;
 		return -EINVAL;
 	}
+	if (ino > ~((u32) 0)) {
+		cd->common.err = nfserr_fbig;
+		return -EINVAL;
+	}
 	*p++ = xdr_one;				/* mark entry present */
 	*p++ = htonl((u32) ino);		/* file id */
 	p    = xdr_encode_array(p, name, namlen);/* name length & name */
--- linux-2.6.22.i686/fs/nfsd/nfs4xdr.c.org
+++ linux-2.6.22.i686/fs/nfsd/nfs4xdr.c
@@ -1657,7 +1657,7 @@ out_acl:
 	if (bmval0 & FATTR4_WORD0_FILEID) {
 		if ((buflen -= 8) < 0)
 			goto out_resource;
-		WRITE64((u64) stat.ino);
+		WRITE64(stat.ino);
 	}
 	if (bmval0 & FATTR4_WORD0_FILES_AVAIL) {
 		if ((buflen -= 8) < 0)
@@ -1799,16 +1799,15 @@ out_acl:
 		WRITE32(stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
-		struct dentry *mnt_pnt, *mnt_root;
-
 		if ((buflen -= 8) < 0)
                 	goto out_resource;
-		mnt_root = exp->ex_mnt->mnt_root;
-		if (mnt_root->d_inode == dentry->d_inode) {
-			mnt_pnt = exp->ex_mnt->mnt_mountpoint;
-			WRITE64((u64) mnt_pnt->d_inode->i_ino);
-		} else
-                	WRITE64((u64) stat.ino);
+		if (exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
+			err = vfs_getattr(exp->ex_mnt->mnt_parent,
+				exp->ex_mnt->mnt_mountpoint, &stat);
+			if (err)
+				goto out_nfserr;
+		}
+                WRITE64(stat.ino);
 	}
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
--- linux-2.6.22.i686/include/linux/nfsd/nfsfh.h.org
+++ linux-2.6.22.i686/include/linux/nfsd/nfsfh.h
@@ -150,17 +150,7 @@ typedef struct svc_fh {
 	struct timespec		fh_pre_ctime;	/* ctime before oper */
 
 	/* Post-op attributes saved in fh_unlock */
-	umode_t			fh_post_mode;	/* i_mode */
-	nlink_t			fh_post_nlink;	/* i_nlink */
-	uid_t			fh_post_uid;	/* i_uid */
-	gid_t			fh_post_gid;	/* i_gid */
-	__u64			fh_post_size;	/* i_size */
-	unsigned long		fh_post_blocks; /* i_blocks */
-	unsigned long		fh_post_blksize;/* i_blksize */
-	__be32			fh_post_rdev[2];/* i_rdev */
-	struct timespec		fh_post_atime;	/* i_atime */
-	struct timespec		fh_post_mtime;	/* i_mtime */
-	struct timespec		fh_post_ctime;	/* i_ctime */
+	struct kstat		fh_post_attr;	/* full attrs after operation */
 #endif /* CONFIG_NFSD_V3 */
 
 } svc_fh;
@@ -297,36 +287,12 @@ fill_pre_wcc(struct svc_fh *fhp)
 	if (!fhp->fh_pre_saved) {
 		fhp->fh_pre_mtime = inode->i_mtime;
 		fhp->fh_pre_ctime = inode->i_ctime;
-			fhp->fh_pre_size  = inode->i_size;
-			fhp->fh_pre_saved = 1;
+		fhp->fh_pre_size  = inode->i_size;
+		fhp->fh_pre_saved = 1;
 	}
 }
 
-/*
- * Fill in the post_op attr for the wcc data
- */
-static inline void
-fill_post_wcc(struct svc_fh *fhp)
-{
-	struct inode    *inode = fhp->fh_dentry->d_inode;
-
-	if (fhp->fh_post_saved)
-		printk("nfsd: inode locked twice during operation.\n");
-
-	fhp->fh_post_mode       = inode->i_mode;
-	fhp->fh_post_nlink      = inode->i_nlink;
-	fhp->fh_post_uid	= inode->i_uid;
-	fhp->fh_post_gid	= inode->i_gid;
-	fhp->fh_post_size       = inode->i_size;
-	fhp->fh_post_blksize    = BLOCK_SIZE;
-	fhp->fh_post_blocks     = inode->i_blocks;
-	fhp->fh_post_rdev[0]    = htonl((u32)imajor(inode));
-	fhp->fh_post_rdev[1]    = htonl((u32)iminor(inode));
-	fhp->fh_post_atime      = inode->i_atime;
-	fhp->fh_post_mtime      = inode->i_mtime;
-	fhp->fh_post_ctime      = inode->i_ctime;
-	fhp->fh_post_saved      = 1;
-}
+extern void fill_post_wcc(struct svc_fh *);
 #else
 #define	fill_pre_wcc(ignored)
 #define fill_post_wcc(notused)
--- linux-2.6.22.i686/include/linux/nfsd/xdr4.h.org
+++ linux-2.6.22.i686/include/linux/nfsd/xdr4.h
@@ -421,8 +421,8 @@ set_change_info(struct nfsd4_change_info
 	cinfo->atomic = 1;
 	cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
 	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
-	cinfo->after_ctime_sec = fhp->fh_post_ctime.tv_sec;
-	cinfo->after_ctime_nsec = fhp->fh_post_ctime.tv_nsec;
+	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
+	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);

--------------080306000308010704060800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------080306000308010704060800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080306000308010704060800--
