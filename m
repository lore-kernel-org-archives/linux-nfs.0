Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f52.google.com ([74.125.83.52]:33155 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790Ab3I3PXr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 11:23:47 -0400
Received: by mail-ee0-f52.google.com with SMTP id c41so2797065eek.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 08:23:46 -0700 (PDT)
Message-ID: <5249977E.5060106@primarydata.com>
Date: Mon, 30 Sep 2013 18:23:42 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org>
In-Reply-To: <20130929123553.GA7510@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:35, Christoph Hellwig wrote:
> On Sun, Sep 29, 2013 at 05:21:30AM -0700, Christoph Hellwig wrote:
>>> Bruce - are you ok with moving the pnfs interface definitions to
>>> include/linux/exportfs.h along with struct export_operations?
>>>
>>> In fact we can actually extend struct export_operations rather
>>> than adding pnfs_export_operations...
>>
>> Yes, it probably should go into the export ops, although the actual
>> method signatures might need to be made a litle less nfs-specific for
>> that.
> 
> I jsut took a brief look over the diff for the whole series in the git
> tree and the old tree that still had block and exofs servers and have
> revised my opinion a little bit:
> 
> 
>  - the should be a layout_type field in struct export_operations,
>    indicating that a filesystem support some sort of pnfs-like export.
>  - there should be a struct pnfs_operations, but it should be confined
>    to fs/nfsd: each layout can be a separate loadable module and gets
>    registered there.  For the initial file layout that module is
>    self-contained, but for e.g. block or objects it would have
>    call into the filesystem through export_ops, although way lower level

This makes sense for blocks for its use of the generic block allocation and mapping
calls (and it needs a new call for committing uninitialized extents)
But for objects there are no such calls and the integration with exofs
is pretty intimate.

Benny

>    than the NFS XDR level, e.g. for block there would be one of to get
>    the extent map, and one to allocate an extent.
> 
> This way we alsod avoid the dependcy on nfsd in the filesystems that the
> cureent version introduces.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
