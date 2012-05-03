Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757787Ab2ECRHz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 May 2012 13:07:55 -0400
Message-ID: <4FA2BB68.7070304@redhat.com>
Date: Thu, 03 May 2012 19:07:52 +0200
From: Niels de Vos <ndevos@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [RFC] Dataloss on NFS-clients who modify an mmap()'d area after
 closing the file-descriptor
References: <4FA2A56B.1030208@redhat.com> <1336059797.5385.22.camel@lade.trondhjem.org>
In-Reply-To: <1336059797.5385.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/03/2012 05:43 PM, Myklebust, Trond wrote:
 > On Thu, 2012-05-03 at 17:34 +0200, Niels de Vos wrote:
 >> When an application on an NFS-client (tested with NFSv3) executes the
 >> following steps, data written after the close() is never flushed to the
 >> server:
 >>
 >> 1. open()
 >> 2. mmap()
 >> 3. close()
 >> 4.<modify data in the mmap'ed area>
 >> 5. munmap()
 >>
 >> Dropping the caches (via /proc/sys/vm/drop_caches) or unmounting does not
 >> result in the data being sent to the server.
 >>
 >> The man-page for mmap (man 2 mmap) does mention that closing the file-
 >> descriptor does not munmap() the area. Using the mmap'ed area after a
 >> close() sound valid to me (even if it may be bad practice).
 >>
 >> Investigation and checking showed that the NFS-client does not handle
 >> munmap(), and only flushes on close(). To solve this problem, least two
 >> solutions can be proposed:
 >>
 >> a. f_ops->release() is called on munmap() as well as on close(),
 >>      therefore release() can be used to flush data as well.
 >> b. In the 'struct vm_operations_struct' add a .close to the
 >>      'struct vm_area_struct' on calling mmap()/nfs_file_mmap() and flush
 >>      the data in the new close() function.
 >>
 >> Solution a. contains currently very few code changes:
 >>
 >> --- a/fs/nfs/inode.c
 >> +++ b/fs/nfs/inode.c
 >> @@ -713,6 +713,8 @@ int nfs_open(struct inode *inode, struct file *filp)
 >>
 >>    int nfs_release(struct inode *inode, struct file *filp)
 >>    {
 >> +       if (S_ISREG(inode->i_mode)&&  inode->i_mapping->nrpages != 0) {
 >> +               nfs_sync_mapping(inode->i_mapping);
 >>           nfs_file_clear_open_context(filp);
 >>           return 0;
 >>    }
 >>
 >> The disadvantage is, that nfs_release() is called on close() too. That
 >> means this causes a flushing of dirty pages, and just after that the
 >> nfs_file_clear_open_context() might flush again. The advantage is that
 >> it is possible (though not done at the moment) to return an error in
 >> case flushing failed.
 >>
 >> Solution b. does not provide an option to return an error, but does not
 >> get called on each close():
 >>
 >> --- a/fs/nfs/file.c
 >> +++ b/fs/nfs/file.c
 >> @@ -547,9 +547,17 @@ out:
 >>    	return ret;
 >>    }
 >>
 >> +static void nfs_vm_close(struct vm_area_struct * vma)
 >> +{
 >> +	struct file *filp = vma->vm_file;
 >> +
 >> +	nfs_file_flush(filp, (fl_owner_t)filp);
 >> +}
 >> +
 >>    static const struct vm_operations_struct nfs_file_vm_ops = {
 >>    	.fault = filemap_fault,
 >>    	.page_mkwrite = nfs_vm_page_mkwrite,
 >> +	.close = nfs_vm_close,
 >>    };
 >>
 >>    static int nfs_need_sync_write(struct file *filp, struct inode *inode)
 >>
 >> I would like some feedback on what solution is most acceptable, or any
 >> other suggestions.
 >
 > Neither solution is acceptable. This isn't a close-to-open cache
 > consistency issue.
 >
 > The syntax of mmap() for both block and NFS mounts is the same: writes
 > are not guaranteed to hit the disk until your application explicitly
 > calls msync().
 >

Okay, that makes sense. But if the application never calls msync(), and
just munmap()'s the area, when should the changes be written? I did not
expect that unmounting just disregards the data.

Any suggestions on correcting this (if it should be corrected) are
welcome.

Thanks again,
Niels
