Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f173.google.com ([209.85.212.173]:55496 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2MUg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:20:36 -0400
Received: by mail-wi0-f173.google.com with SMTP id hq15so2624813wib.0
        for <linux-nfs@vger.kernel.org>; Sun, 29 Sep 2013 05:20:35 -0700 (PDT)
Message-ID: <52481B11.2080407@primarydata.com>
Date: Sun, 29 Sep 2013 15:20:33 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org>
In-Reply-To: <20130929121345.GA21083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:13, Christoph Hellwig wrote:
> On Sun, Sep 29, 2013 at 03:12:41PM +0300, Benny Halevy wrote:
>>> Also why would you want a header
>>> outside fs/nfsd/ ?
>>
>> This header contains the file system interface.
> 
> Any interface for the filesystem should be part of exportfs.h, not
> something nfs-specific.

Makes sense.  Thanks.

Bruce - are you ok with moving the pnfs interface definitions to
include/linux/exportfs.h along with struct export_operations?

In fact we can actually extend struct export_operations rather
than adding pnfs_export_operations...

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
