Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f45.google.com ([74.125.83.45]:62144 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab3I3PZJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 11:25:09 -0400
Received: by mail-ee0-f45.google.com with SMTP id c50so2786307eek.18
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 08:25:08 -0700 (PDT)
Message-ID: <524997D1.90202@primarydata.com>
Date: Mon, 30 Sep 2013 18:25:05 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 11/49] NFSD: introduce exp_xdr.h
References: <52447EA0.7070004@primarydata.com> <1380220835-13182-1-git-send-email-bhalevy@primarydata.com> <20130929121517.GC21083@infradead.org>
In-Reply-To: <20130929121517.GC21083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:15, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:40:35PM -0400, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@panasas.com>
>>
>> Containing xdr encoding helpers to be used by the layout type library functions
>> or by the file system to encode/decode layout-type specific device and layout
>> information.
> 
> Any reason why pnfs would use this, but not the rest of nfsd?  Maybe
> this should go in as part of a separate series cleaning up the xdr
> encoding and decoding?

I discussed this with Trond and this patch is dropped from the next version
of this patchset.  nfs4.h is going to be included instead.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
