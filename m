Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:43219 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068Ab3KEOYE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Nov 2013 09:24:04 -0500
Message-ID: <5278FF7F.4020000@netapp.com>
Date: Tue, 5 Nov 2013 09:23:59 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-4-git-send-email-bjschuma@netapp.com> <20131105094016.GA7186@infradead.org>
In-Reply-To: <20131105094016.GA7186@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/05/2013 04:40 AM, Christoph Hellwig wrote:
>> +{
>> +	int error, mode = 0;
>> +
>> +	if (allocated == false)
>> +		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
>> +
>> +	error = do_fallocate(file, mode, offset, len);
>> +	if (error == 0)
>> +		error = vfs_fsync_range(file, offset, offset + len, 0);
>> +	return nfserrno(error);
> 
> Same problem with the falloc vs WRITE_PLUS mismatch here.  For XFS you
> could make the allocated case all XFS_IOC_ZERO_RANGE, but the proposed
> VFS equivalent never seemed to have made it in.
> 
> Also no need for the FALLOC_FL_KEEP_SIZE in the hole punch case, it is
> ignored.
> 

It's not ignored in do_fallocate() (fs/open.c) where it returns -EOPNOTSUPP if FALLOC_FL_PUNCH_HOLE is set without FALLOC_FL_KEEP_SIZE :)
