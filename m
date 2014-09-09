Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:47857 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbaIITRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 15:17:09 -0400
Message-ID: <540F5230.3000804@Netapp.com>
Date: Tue, 9 Sep 2014 15:17:04 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] nfsd: Add ALLOCATE support
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com> <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com> <20140909155518.GB21928@infradead.org>
In-Reply-To: <20140909155518.GB21928@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/09/2014 11:55 AM, Christoph Hellwig wrote:
> On Tue, Sep 09, 2014 at 10:49:41AM -0400, Anna.Schumaker@netapp.com wrote:
>> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>
>> The ALLOCATE operation is used to preallocate space in a file.  I use
>> vfs_fallocate() to do the actual preallocation.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Looks largely good, but can you do an audit how the error codes match
> the spec?  E.g. We return -ENODEV in do_fallocate if it's called on
> a special file, but that doesn't translate to any valid error codes
> for ALLOCATE in the NFSv4.2.

Good idea, I'll look into it!

Anna
> 
> I guess it should be NFSERR_NOTSUPP, and I'll work with Tom to actually
> define this case in the spec.
> 

