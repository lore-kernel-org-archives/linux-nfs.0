Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20534 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab3KDQlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 11:41:20 -0500
Message-ID: <5277CE23.6010207@netapp.com>
Date: Mon, 4 Nov 2013 11:41:07 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-4-git-send-email-bjschuma@netapp.com> <20131102135238.GB18961@infradead.org>
In-Reply-To: <20131102135238.GB18961@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/02/2013 09:52 AM, Christoph Hellwig wrote:
>> +__be32 nfsd4_vfs_fallocate(struct file *file, bool allocated, loff_t offset, loff_t len)
>> +{
>> +	int error, mode = 0;
>> +
>> +	if (allocated == false)
>> +		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
>> +
>> +	error = do_fallocate(file, mode, offset, len);
>> +	if (error == 0)
>> +		error = vfs_fsync_range(file, offset, offset + len, 0);
> 
> What are you trying to do with the fsync_range here?  If it's just to
> make sure the metadata operation is stable on disk please use commit_metadata()
> from fs/nfsd/vfs.c.  As there's no data involved here I can't really see
> what else it would be for.

My understanding is that if I call fallocate with a mode of "0" it will write a range of 0s to the file.  I'll move the fsync() call here and only do it if the client doesn't ask for NFS_UNSTABLE.

> 
> 
> Also the allocated flag doesn't make any sense for people not taking the
> same drugs as the spec authors, please add a comment what it means.

Sure

> 
> Btw, how did anyone come up with the name WRITE PLUS for something that
> doesn't actually involve any writes?
> 

Write plus does write more than just holes, I just didn't implement that part of the spec.  I'm implementing the NFS4_CONTENT_HOLE arm, but NFS4_CONTENT_DATA is intended to eventually replace the WRITE operation.

