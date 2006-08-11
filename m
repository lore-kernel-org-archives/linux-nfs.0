From: Neil Brown <neilb@suse.de>
Subject: How best to handle races between mmap/flush and truncate in
	NFS.
Date: Fri, 11 Aug 2006 15:33:01 +1000
Message-ID: <17628.5773.954140.608180@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBPdw-0005NO-HD
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 22:33:12 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GBPdw-00051P-Hk
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 22:33:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


Hi, 
 I've had a bug report for sles10 that relates to a race as mentioned
 in the subject.
 I think that the code currently in mainline would possibly handling
 it better than current sles10, but I would appreciate at least if
 someone could check my understanding, to make sure I know what is
 going on.

 The race goes like this.

   One process mmaps a file and writes to it.  Maybe it calls msync
   occasionally or maybe just general flushing causes pages to get
   written out.

   Another process calls 'truncate'.  This causes a SETATTR(size==0)
   request to be sent out, but the local mappings are not truncated
   until the reply returns (the mappings are flushed, but new dirty 
   data has plenty of time to accumulate).

   So when the vmtruncate is finally called, some page that is about
   to be truncated has an outstanding write request on it.
   nfs_invalidatepage cannot cope with that and bugs-out.
   In later mainline kernels nfs_invalidatepage will clear out any
   pending write requests to truncation can complete safely.  But
   I'm not sure that this is a complete solution.

With current mainline, the above situation will mean that the
client sends a SETATTR to truncate and then a WRITE.  This will
result, on the server, in the file being truncated and then
extended.  I don't think this should happen.  Normally mmap
based writes cannot write past EOF (I don't think).  But in
this case it effectively does.

What I would propose is that in nfs_setattr (fs/nfs/inode.c)
we set i_size down early and call unmap_mapping_range.
This will flush out any dirty mapping, and disable any mmapped access
to pages past the new EOF:

	/* Write all dirty data */
+	if (attr->ia_valid & ATTR_SIZE &&
+	    attr->ia_size < i_size_read(inode)) {
+		/* We really need to set i_size early to ensure that
+		 * no new pages get written while we are truncating.
+		 */
+		i_size_write(inode, attr->ia_size);
+		unmap_mapping_range(mapping, attr->ia_size + PAGE_SIZE - 1, 0, 1);
+		/* Now new mappings > size will fail */
+	}
	filemap_write_and_wait(inode->i_mapping);
	nfs_wb_all(inode);


This runs a risk (small) that the SETATTR will fail and we will have 
already reduced the size of the file (though not purged the
address_space). 
So after the ->setattr call we check for failure and set
NFS_INO_INVALID_ATTR if the SETATTR failed.

	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
	if (error == 0)
		nfs_refresh_inode(inode, &fattr);
+	else if (attr->ia_valid & ATTR_SIZE) {
+		/* Oops, we changed the i_size locally, but 
+		 * failed to set it on the server.
+		 * better revalidate the size
+		 */
+		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
+	}

This means that there cannot be any writes happening during the
truncate call (normal write(2) is excluded by i_mutex, and this patch
excluded mmap write by setting i_size).  So nfs_invalidatepage will
never find a page with a pending write that needs to be dealt with.

Does this make any sense?  It is hopelessly wrong?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
