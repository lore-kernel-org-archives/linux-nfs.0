Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49066 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbaJWVYz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2014 17:24:55 -0400
Message-ID: <544971CE.9090808@Netapp.com>
Date: Thu, 23 Oct 2014 17:23:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: <viro@zeniv.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <bfields@fieldses.org>,
        <Trond.Myklebust@primarydata.com>
Subject: Re: [PATCH] VFS: Rename do_fallocate() to vfs_fallocate()
References: <1412190907-30307-1-git-send-email-Anna.Schumaker@Netapp.com> <20141001210451.GB6680@lst.de>
In-Reply-To: <20141001210451.GB6680@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm curious what the status of this patch is?

Thanks,
Anna

On 10/01/2014 05:04 PM, Christoph Hellwig wrote:
> On Wed, Oct 01, 2014 at 03:15:07PM -0400, Anna Schumaker wrote:
>> From: Anna Schumaker <Anna.Schumaker@netapp.com>
>>
>> This function needs to be exported so it can be used by the NFSD module
>> when responding to the new ALLOCATE and DEALLOCATE operations in NFS
>> v4.2.  Christoph Hellwig suggested renaming the function to stay
>> consistent with how other vfs functions are named.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Acked-by: Christoph Hellwig <hch@lst.de>
> 

