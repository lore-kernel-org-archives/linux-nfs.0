Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:6830 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbaJ1TJY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 15:09:24 -0400
Message-ID: <544FE9E1.5070501@Netapp.com>
Date: Tue, 28 Oct 2014 15:09:21 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] nfsd: Add ALLOCATE support
References: <1414161705-26617-1-git-send-email-Anna.Schumaker@Netapp.com> <1414161705-26617-2-git-send-email-Anna.Schumaker@Netapp.com> <20141028084108.GC25532@infradead.org>
In-Reply-To: <20141028084108.GC25532@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2014 04:41 AM, Christoph Hellwig wrote:
>> +	error = vfs_fallocate(file, flags, offset, len);
>> +	if (error == -ENODEV)
>> +		return nfserr_inval;
>> +	else if (error < 0)
>> +		return nfserrno(error);
>> +	return nfserrno(commit_metadata(fhp));
> 
> 
> Shouldn't this be something like:
> 
> 	error = vfs_fallocate(file, flags, offset, len);
> 	if (!error)
> 		error = commit_metadata(fhp);
> 
> 	if (error == -ENODEV)
> 		return nfserr_inval;
> 	return nfserrno(error);

Sure.  I'll post another version in the next few days (with the other patch included).

Thanks for the feedback!
Anna

> 
> I think we really should move the ENODEV mapping to nfserrno, but
> this patch isn't the right place for that.
> 

