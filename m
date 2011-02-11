Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41664 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756439Ab1BKP3m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:29:42 -0500
Date: Fri, 11 Feb 2011 10:29:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [bfields@pop.test.fieldses.org: all 4c5fcc5e SQUASHME: pnfs-obj:
 use pnfs_layout_hdr and layout_segment field prefix results]
Message-ID: <20110211152941.GB3005@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is this something that only shows when pnfs is configured out, maybe?

--b.

----- Forwarded message from "J. Bruce Fields" <bfields@pop.test.fieldses.org> -----

Date: Fri, 11 Feb 2011 02:42:18 -0500
From: "J. Bruce Fields" <bfields@pop.test.fieldses.org>
To: bfields@fieldses.org
Subject: all 4c5fcc5e SQUASHME: pnfs-obj: use pnfs_layout_hdr and
	layout_segment field prefix results

6210 all 4c5fcc5e SQUASHME: pnfs-obj: use pnfs_layout_hdr and layout_segment field prefix
fs/cifs/file.c: In function 'cifs_iovec_write':
fs/cifs/file.c:1740: warning: passing argument 6 of 'CIFSSMBWrite2' from incompatible pointer type
fs/cifs/cifsproto.h:343: note: expected 'unsigned int *' but argument is of type 'size_t *'
fs/cifs/link.c: In function 'symlink_hash':
fs/cifs/link.c:58: warning: 'rc' may be used uninitialized in this function
fs/cifs/smbencrypt.c: In function 'mdfour':
fs/cifs/smbencrypt.c:61: warning: 'rc' may be used uninitialized in this function
In file included from include/linux/nfsd/nfsd4_pnfs.h:39,
                 from include/linux/nfsd/nfs4layoutxdr.h:38,
                 from fs/nfsd/nfs4proc.c:37:
include/linux/nfs_xdr.h:1124: error: field 'refcount' has incomplete type
make[2]: *** [fs/nfsd/nfs4proc.o] Error 1
make[1]: *** [fs/nfsd] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [fs] Error 2
make: *** Waiting for unfinished jobs....

started Fri Feb 11 02:22:03 EST 2011, finished Fri Feb 11 02:42:18 EST 2011


+-----------------------------------------+
|            verbose output               |
+-----------------------------------------+

----- End forwarded message -----
