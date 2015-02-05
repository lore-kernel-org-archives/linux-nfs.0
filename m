Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:44039 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265AbbBEObx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:31:53 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so8005922wes.7
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 06:31:51 -0800 (PST)
Message-ID: <54D37ED5.1020106@plexistor.com>
Date: Thu, 05 Feb 2015 16:31:49 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>
CC: Anna Schumaker <Anna.Schumaker@netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fsx: check for filesystem support of FALLOCATE_FL_KEEP_SIZE
References: <1422997783-22484-1-git-send-email-Anna.Schumaker@Netapp.com> <54D37B33.9090501@plexistor.com> <20150205142235.GA24816@infradead.org>
In-Reply-To: <20150205142235.GA24816@infradead.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 04:22 PM, Christoph Hellwig wrote:
> On Thu, Feb 05, 2015 at 04:16:19PM +0200, Boaz Harrosh wrote:
>> On 02/03/2015 11:09 PM, Anna Schumaker wrote:
>>> The NFS implementation of fallocate() does not support passing the
>>> KEEP_SIZE flag by itself, causing tests to randomly fail.
>>>
>>
>> This I do not understand please explain. If all the other FSs just ignore
>> a trivial case, then why should NFS not ignore it the same as all
>> other filesystems.
>>
>> Why NFS is allowed to be special. (And apparently break user code xfs
>> being an example of one)
> 
> fsx is a test tool.  We've never guaranteed that a filesystem needs to
> support all or a special subset of fallocate options.
> 
> The NFSv4.2 protocol doesn't support preallocations beyond the file
> size, which is something I decided would be to horrible to refit into
> the NFS file abstraction when rewriting the preallocation / reservation
> section of the spec.

Ha OK now I understand. KEEP_SIZE is not supported when allocating blocks.

Pity, it is very useful for exactly those that need fallocte like video files.
Perhaps in the next version, thanks.

Boaz

