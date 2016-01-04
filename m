Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:53814 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbcADUFs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 15:05:48 -0500
Subject: Re: [PATCH v2 3/3] NFS: Add COPY nfs operation
To: Christoph Hellwig <hch@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-4-git-send-email-Anna.Schumaker@Netapp.com>
 <20151220155321.GC18236@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <568AD096.1010305@Netapp.com>
Date: Mon, 4 Jan 2016 15:05:42 -0500
MIME-Version: 1.0
In-Reply-To: <20151220155321.GC18236@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/20/2015 10:53 AM, Christoph Hellwig wrote:
>> +	if (res.write_res.committed != NFS_FILE_SYNC) {
>> +		status = nfs42_proc_commit(dst, pos_dst, res.write_res.count);
>> +		if (status)
>> +			return status;
>> +	}
> 
> Do we really expect data to be stabe on disk after a copy_file_range?
> Seems like the page cache variant doesn't guarantee that, and it would
> also be different from all other I/O syscalls.

It doesn't have to be, I just couldn't figure out how to mark the range as "needs commit" for the next time somebody runs fsync().

Anna

> 
> Either way we will probably need to document the assumptions in the man
> page.
> 

