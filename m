From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
Date: Thu, 31 Mar 2011 08:53:58 +0200
Message-ID: <4D942506.1020505@panasas.com>
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com> <20110330155811.GA21931@lst.de> <4D936453.2070501@panasas.com> <20110330173344.GA24631@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rees <rees@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49571 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab1CaGyb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 02:54:31 -0400
Received: by fxm17 with SMTP id 17so1604237fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2011 23:54:30 -0700 (PDT)
In-Reply-To: <20110330173344.GA24631@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-03-30 19:33, Christoph Hellwig wrote:

> On Wed, Mar 30, 2011 at 07:11:47PM +0200, Benny Halevy wrote:
>> Makes sense. This could also be done by adding a respective flags argument
>> to fallocate and have a common wrapper function look at the file descriptor
>> and call the fs fallocate, that could then get the inode rather the file.
>> In other words, why copy code rather than factor it out into a common
>> function?
> We can discuss that _iff_ a valid use for a file-less fallocate appears
> in mainline.  The pnfs-block one is not.  It's just a racy hack, which
> opens gapping holes.  Take a look what it does - it allocates block for
> a client to write into directly, with absolutely zero guarantee the
> block allocation actually stays around until that point.
>
> You'll need to have some outstanding token on extent map changes like
> done in CXFS or NEC's "gfs" which implemented something similar to pnfs
> based on nfsv3.

Agreed.

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

