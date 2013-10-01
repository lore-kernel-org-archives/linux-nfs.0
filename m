Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36635 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab3JABFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 21:05:46 -0400
Message-ID: <524A1FCE.5030306@panasas.com>
Date: Mon, 30 Sep 2013 18:05:18 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Benny Halevy <bhalevy@primarydata.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org>
In-Reply-To: <20130929123553.GA7510@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/29/2013 05:35 AM, Christoph Hellwig wrote:> On Sun, Sep 29, 2013 at 05:21:30AM -0700, Christoph Hellwig wrote:
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

The pnfs protocol and people have plans to, allow a multi typed
layouts from the same super-block. It is a per file attribute.
It even allows a multi protocol access to the same file.
The only flag should be the presence of the layout_get vector
that should indicate support or lack of it.

(In fact I would remove layout_type field completly it's place
 is only as an input to LO_GET and DEVICE_INFO)

>  - there should be a struct pnfs_operations, but it should be confined
>    to fs/nfsd: each layout can be a separate loadable module and gets
>    registered there.  For the initial file layout that module is
>    self-contained, but for e.g. block or objects it would have
>    call into the filesystem through export_ops, although way lower level
>    than the NFS XDR level, e.g. for block there would be one of to get
>    the extent map, and one to allocate an extent.
>

No! This does not make any sense. What you say does not fit any model of any
cluster filesystem today.

- Again the FS can support any protocol.
- Only the FS understand the structure and layout of the file access. Any
  other model is a specific implementation and breaks abstraction. The only true
  abstraction is the LO_GET LO_RETURN LO_COMMIT DEVICE_INFO and LO_CB_RECALL. anything
  else is making assumptions.

There is a pnfs vector and it is at this abstraction level exactly.

> This way we alsod avoid the dependcy on nfsd in the filesystems that the
> cureent version introduces.

There is no "dependency on nfsd in the filesystems"

The only dependency the FS has is an import of some library routines
at exportfs that take an abstract layout and device descriptions and encode
them into an XDR buffer. But the FS knows nothing of the XDR and the
NFSD is free to unload at any moment without forcing the FS to unload
first or at all.
This is actually tested, in fact I do this all the time when I want to
start fresh and have NFSD close all resources on the FS. 

Nothing changed, the FS is independent and NFSD is dependent on the FS,
but in an abstract way via an exports vector.

Where did you see such dependency?


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


Cheers
Boaz
