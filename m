Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:8811 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbbLDPtc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2015 10:49:32 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 2/3] NFSD: Implement the COPY call
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20151204154549.GD26898@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <hch@infradead.org>
Message-ID: <5661B604.1010402@Netapp.com>
Date: Fri, 4 Dec 2015 10:49:24 -0500
MIME-Version: 1.0
In-Reply-To: <20151204154549.GD26898@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/04/2015 10:45 AM, J. Bruce Fields wrote:
> On Thu, Dec 03, 2015 at 03:55:35PM -0500, Anna Schumaker wrote:
>> @@ -498,6 +499,22 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  }
>>  #endif
>>  
>> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
>> +		       struct file *dst, u64 dst_pos,
>> +		       u64 count)
>> +{
>> +	ssize_t bytes;
>> +	u64 limit = 0x10000000;
> 
> Why that value?  Could I get a comment here?

Whoops!  I had a comment there at one point, but I must have deleted it :(.  That value is to cap copies to 256MB.
> 
>> +
>> +	if (count > limit)
>> +		count = limit;
>> +
>> +	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
> 
> Sorry, I lost track of the copy discussions: does this only work on
> filesystems with special support, or does it fall back on doing the copy
> by hand?  Which filesystems (of the exportable filesystems) support
> this?

The system call falls back on doing the copy by hand if there is no filesystem acceleration.

Anna

> 
> --b.
> 
>> +	if (bytes > 0)
>> +		vfs_fsync_range(dst, dst_pos, dst_pos + bytes, 0);
>> +	return bytes;
>> +}
>> +
>>  __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  			   struct file *file, loff_t offset, loff_t len,
>>  			   int flags)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

