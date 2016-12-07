Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932661AbcLGTkS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 14:40:18 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Serialize nfs_readdir()
Date: Wed, 07 Dec 2016 14:40:15 -0500
Message-ID: <7B5C9F8D-B03E-4243-AE65-61419DF10C47@redhat.com>
In-Reply-To: <20161207163026.GA9166@infradead.org>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <a87df5d5ada87834a1cb9f1ab12ed5113d80eda7.1481117708.git.bcodding@redhat.com>
 <20161207163026.GA9166@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 Dec 2016, at 11:30, Christoph Hellwig wrote:

> On Wed, Dec 07, 2016 at 08:37:02AM -0500, Benjamin Coddington wrote:
>> Optimizations to NFS to choose between READDIR and READDIRPLUS don't 
>> expect
>> concurrent users of nfs_readdir(), and can cause the pagecache to
>> repeatedly be invalidated unnecessarily for this case.  Fix this by
>> serializing nfs_readdir() on the directory's rwsem.
>
> Just implement .iterate instead of .iterate_shared and you'll get the
> serialization for free.  While doing that please add a comment on why
> it's serialized.

I had it in my head that Al was trying to get rid of .iterate, otherwise
yes, this would be more sensible.  I think it'll still benefit from
.iterate_shared in the regular case (the case where we're not trying to 
use
READDIRPLUS), so I'll try out Trond's suggestion to fix it up before 
chasing
this down.

Ben
