Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:62628 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbaCTMuX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Mar 2014 08:50:23 -0400
Received: by mail-qa0-f53.google.com with SMTP id w8so770916qac.12
        for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 05:50:22 -0700 (PDT)
Message-ID: <532AE40B.4000807@gmail.com>
Date: Thu, 20 Mar 2014 08:50:19 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2 v2] nfs: remove ->write_pageio_init from rpc ops
References: <20140319164003.GA26364@infradead.org> <5329D82A.6040102@gmail.com> <20140320100414.GA28919@infradead.org>
In-Reply-To: <20140320100414.GA28919@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/20/2014 06:04 AM, Christoph Hellwig wrote:
> On Wed, Mar 19, 2014 at 01:47:22PM -0400, Anna Schumaker wrote:
>>>  }
>>> -EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
>> I think we still need the EXPORT_SYMBOL_GPL() here.  Compiling gives me:
>>
>> ERROR: "nfs_pageio_init_read" [fs/nfs/nfsv4.ko] undefined!
>> ERROR: "nfs_pageio_init_write" [fs/nfs/nfsv4.ko] undefined!
> Oh right - I only tested built-in nfs.   I have to say the amount of
> fairly low-level interfaces exported from the various nfs modules make a
> bit of a mess..
>
I'm open to suggestions about how to clean it all up!  Fewer EXPORT_SYMBOLS wouldn't be a bad thing (along with fewer ifdefs and fewer rpc ops ...)
