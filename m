From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Subject: nfs_file_flush() question
Date: Sat, 16 Aug 2008 19:23:42 -0500
Message-ID: <20080817002342.GA17223@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip4-fw.champ.corp.yahoo.com ([64.198.211.64]:51177 "EHLO
	enemycanmeet.champ.corp.yahoo.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751663AbYHQAuF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Aug 2008 20:50:05 -0400
Received: from enemycanmeet.champ.corp.yahoo.com (localhost.localdomain [127.0.0.1])
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8) with ESMTP id m7H0NgJX017303
	for <linux-nfs@vger.kernel.org>; Sat, 16 Aug 2008 19:23:42 -0500
Received: (from qbarnes@localhost)
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8/Submit) id m7H0NgdI017302
	for linux-nfs@vger.kernel.org; Sat, 16 Aug 2008 19:23:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been coming up to speed on the NFS protocol and its NFS client
support in Linux.  I've been comparing performance of NFS on RHEL4
and RHEL5 vs. FreeBSD 6.2.  (Okay, we're on an old base, but I don't
think it matters here for this question.)

In watching the NFS protocols fly back and forth between BSD
and Linux clients to an NFS server, I noticed that Linux is
doing an extra GETATTR over FreeBSD when closing a read-write
file.  I tracked this back to nfs_file_flush() which is
doing a __nfs_revalidate_inode() (or in current kernels
nfs_revalidate_inode()).  Why do we want nfs_file_flush() to force
a revalidate of an inode we're closing?  Why not instead just
invalidate the inode's attribute?

I looked at the FreeBSD 6.2 code.  In its nfs_close(), it does an
"np->n_attrstamp = 0;" to invalidate the inode's attribute cache.

The current Linux kernel code in question in nfs_file_flush() is:
==========
    /* Ensure that data+attribute caches are up to date after close() */
    status = nfs_do_fsync(ctx, inode);
    if (!status)
            nfs_revalidate_inode(NFS_SERVER(inode), inode);
==========

I would imagine this better as:
==========
    /* Ensure that data+attribute caches are up to date after close() */
    status = nfs_do_fsync(ctx, inode);
    if (!status && !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))
            NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
==========

Is there a reason I'm missing that the revalidate and GETATTR are
required?

Quentin
