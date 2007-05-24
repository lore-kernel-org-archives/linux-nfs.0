From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: possible bug/oops in nfs_pageio_add_request (2.6.22-rc2)?
Date: Wed, 23 May 2007 21:16:55 -0400
Message-ID: <200705240116.l4O1GtXr020084@agora.fsl.cs.sunysb.edu>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Cc: mhalcrow@us.ibm.com
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: Your message of "Tue, 11 Apr 2006 13:45:43 EDT."
             <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

I've hit a NULL ptr deref on desc->pg_error below, triggered when mounting a
stackable file system on top of nfsv3:

// from file: nfs/pagelist.c
int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
			   struct nfs_page *req)
{
	while (!nfs_pageio_do_add_request(desc, req)) {
		nfs_pageio_doio(desc);
		if (desc->pg_error < 0)

Scenario:

2.6.22-rc2 with Unionfs 2.0 (release u2 for 2.6.22-rc2, which includes mmap
support).

I mount unionfs on top of nfs (v3).  I have one file in the nfs branch.  I
run a simple program through the union which mmap's the file, changes the
first byte of the file, calls msync(), and then closes.  This causes
unionfs_writepage to be invoked, which in turn calls the lower file system's
->writepage, here nfs_writepage.

The 'wbc' that's passed to unionfs_writepage from the VFS has this:

    wbc->for_writepages = 1
    wbc->fs_private = NULL

If you follow the logic, then nfs_writepage calls nfs_writepage_locked,
passing the same wbc.  nfs_writepage_locked does this:

	if (wbc->for_writepages)
		pgio = wbc->fs_private;
	else {
		nfs_pageio_init_write(&mypgio, inode, wb_priority(wbc));
		pgio = &mypgio;
	}

which means that pgio is set to NULL from the caller's wbc.  Then
nfs_writepage_locked calls nfs_page_async_flush, passing it this pgio
(NULL).  nfs_page_async_flush invokes nfs_pageio_add_request, passing it
this NULL pgio.  Inside nfs_pageio_add_request the NULL is being
dereferenced as desc->pg_error and we get an oops.

As a workaround, in unionfs_writepage I tried this before calling the lower
file system's ->writepage (which was nfs_writepage):

	struct writeback_control lower_wbc;
	memcpy(&lower_wbc, wbc, sizeof(struct writeback_control));
	if (lower_wbc.for_writepages && !lower_wbc.fs_private) {
		printk("unionfs: setting wbc.for_writepages to 0\n");
		lower_wbc.for_writepages = 0;
	}

Then I passed &lower_wbc to the lower file system's writepage method
(nfs_writepage).  It works; no oops, and the file in question was sync'ed to
the backing f/s too.  But I'm not sure if it's the correct workaround and
whether it'd break things for other non-NFS file systems.

It's possible that I'm doing something wrong in unionfs's mmap code, which
indirectly results in a malformed wbc structure being passed to unionfs (by
malformed I mean that wbc->fs_private is NULL and wbc->for_writepages is set
to 1).  If such a wbc can be created by any other means and passed to NFS,
then nfs probably will continue to oops even w/o unionfs.

FWIW, I tried a similar scenario with eCryptfs (another stackable f/s in
2.6.22-rc2) on top of NFSv3, and got the same oops (sorry, Mike :-)

Any pointers would be appreciated.

Thanks,
Erez.
