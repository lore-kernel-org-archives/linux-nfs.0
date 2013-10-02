Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:63956 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab3JBLg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 07:36:58 -0400
Received: by mail-we0-f175.google.com with SMTP id t61so635498wes.34
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 04:36:57 -0700 (PDT)
Message-ID: <524C0556.9070705@primarydata.com>
Date: Wed, 02 Oct 2013 14:36:54 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org> <20131001203047.GH16245@pad.fieldses.org>
In-Reply-To: <20131001203047.GH16245@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-01 23:30, J. Bruce Fields wrote:
> On Sun, Sep 29, 2013 at 05:35:53AM -0700, Christoph Hellwig wrote:
>> On Sun, Sep 29, 2013 at 05:21:30AM -0700, Christoph Hellwig wrote:
>>>> Bruce - are you ok with moving the pnfs interface definitions to
>>>> include/linux/exportfs.h along with struct export_operations?
>>>>
>>>> In fact we can actually extend struct export_operations rather
>>>> than adding pnfs_export_operations...
>>>
>>> Yes, it probably should go into the export ops, although the actual
>>> method signatures might need to be made a litle less nfs-specific for
>>> that.
>>
>> I jsut took a brief look over the diff for the whole series in the git
>> tree and the old tree that still had block and exofs servers and have
>> revised my opinion a little bit:
>>
>>
>>  - the should be a layout_type field in struct export_operations,
>>    indicating that a filesystem support some sort of pnfs-like export.
>>  - there should be a struct pnfs_operations, but it should be confined
>>    to fs/nfsd: each layout can be a separate loadable module and gets
>>    registered there.  For the initial file layout that module is
>>    self-contained, but for e.g. block or objects it would have
>>    call into the filesystem through export_ops, although way lower level
>>    than the NFS XDR level, e.g. for block there would be one of to get
>>    the extent map, and one to allocate an extent.
> 
> That sounds OK to me.
> 
> My (possibly faulty) memory of how the xdr-encoding-in-the-fs came
> about: I think people weren't willing to commit to any reasonable upper
> limit on the size of the layout.  So they originally considered
> something more like readdir that would loop over extents and pass them
> to a callback for encoding.  But xdr isn't complicated so you could
> instead give the filesystem a simple library of xdr encoders to call.
> 
> But it sounds like that's not exactly what got implemented.  And maybe
> nobody actually has such big layouts.
> 
>> This way we alsod avoid the dependcy on nfsd in the filesystems that the
>> cureent version introduces.
> 
> Ugh--thanks for catching that.

I suggest moving the code in fs/nfsd/nfs4pnfsdlm.c to
fs/dlm.

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
