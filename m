Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50694 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbaKKMgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 07:36:49 -0500
Received: by mail-wg0-f44.google.com with SMTP id x12so11467284wgg.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 04:36:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141111102735.GB17313@lst.de>
References: <1415448664-25815-1-git-send-email-hch@lst.de>
	<1415448664-25815-3-git-send-email-hch@lst.de>
	<20141110175424.GC32702@fieldses.org>
	<20141111102735.GB17313@lst.de>
Date: Tue, 11 Nov 2014 07:36:48 -0500
Message-ID: <CAHQdGtRKj+8HGV4-bFKGAvD+38Vu8MzjBq16wdgaiDmoe2hqiQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 5:27 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Nov 10, 2014 at 12:54:24PM -0500, J. Bruce Fields wrote:
>> Shouldn't that be NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR?
>>
>> The draft says that e.g. "If the client sees
>> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER, it has the ability to predict what
>> the resulting change attribute value should be after a COMPOUND
>> containing a SETATTR, WRITE, or CREATE."
>>
>> Admittedly, I'm not completely sure what that means.  (Is a SETATTR of
>> multiple attributes a single atomic change?  Can we predict the change
>> attribute on a newly created file, or only on the parent directory?)  I
>> also don't know where the filesystems do the i_version increment (can we
>> guarantee it happens once per nfs WRITE?).
>
> Actually the server may increment it many times for a single WRITE,
> for XFS it is incremented for each dirty transaction, which could
> happen many times during a single write:
>
>  (1) c/mtime update
>  (2) suid/sgid bit removal
>  (3) block allocation (could be multiple transactions)
>
>
> So I guess we really should move to NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR
> instead.

Agreed.

Just out of curiosity, though, why does XFS update i_version on every
block allocation? For NFSv4 compatibility, it really should suffice
for it to just do the update once in the above case. Did Lustre have
more stringent requirements?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
