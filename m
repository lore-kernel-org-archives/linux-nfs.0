Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34851 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab3JBLfp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 07:35:45 -0400
Received: by mail-wi0-f178.google.com with SMTP id hn9so737998wib.11
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 04:35:44 -0700 (PDT)
Message-ID: <524C050E.4010102@primarydata.com>
Date: Wed, 02 Oct 2013 14:35:42 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <52447EA0.7070004@primarydata.com> <1380220810-12909-1-git-send-email-bhalevy@primarydata.com> <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org> <524A1FCE.5030306@panasas.com> <20131001133335.GB32431@infradead.org>
In-Reply-To: <20131001133335.GB32431@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-01 16:33, Christoph Hellwig wrote:
> On Mon, Sep 30, 2013 at 06:05:18PM -0700, Boaz Harrosh wrote:
>> The pnfs protocol and people have plans to, allow a multi typed
>> layouts from the same super-block. It is a per file attribute.
>> It even allows a multi protocol access to the same file.
>> The only flag should be the presence of the layout_get vector
>> that should indicate support or lack of it.
> 
> The current method doesn't help with that as it can return a single type
> only anyway.  So in principle I agree with you, but the way to fix it is
> not to keep the method, but to make sure it returns a bitmap of
> supported layouts.
> 
>>>  - there should be a struct pnfs_operations, but it should be confined
>>>    to fs/nfsd: each layout can be a separate loadable module and gets
>>>    registered there.  For the initial file layout that module is
>>>    self-contained, but for e.g. block or objects it would have
>>>    call into the filesystem through export_ops, although way lower level
>>>    than the NFS XDR level, e.g. for block there would be one of to get
>>>    the extent map, and one to allocate an extent.
>>>
>>
>> No! This does not make any sense. What you say does not fit any model of any
>> cluster filesystem today.
>>
>> - Again the FS can support any protocol.
>> - Only the FS understand the structure and layout of the file access. Any
>>   other model is a specific implementation and breaks abstraction. The only true
>>   abstraction is the LO_GET LO_RETURN LO_COMMIT DEVICE_INFO and LO_CB_RECALL. anything
>>   else is making assumptions.
>>
>> There is a pnfs vector and it is at this abstraction level exactly.
> 
> No, the problem is that the pnfs_export_operations are entirely at the
> wrong level, as I tried to explain.  The right level is very different
> for the different layouts:
> 
>  - for files it needs to boil down to a:
> 
> 	 - get a list of devices
> 	 - given an inode/offset return the layout
> 

For loosely clustered files-layout file systems the MDS would also
need to handle LAYOUTCOMMIT, and also generate and handle layout recalls,
depending on how much of that we can do in a generic way and how much is
file system specific.

>  - for block it's get a block map for a file / create an unwritten
>    extent / convert it to written

Besides converting to written there is also de-allocation of provisionally
allocated extents and more advanced stuff for client assisted copy-on-write
where after allocation of uninitialized extents the client can commit
extents to the block map by replacing existing initialized extents with
new ones.

> 
>  - for object it seems (not too familar):
> 
>     - get a list of devices for this fs
>     - given an inode/offset return the layout
>     - tell the fs that I/O has finished
> 
> As all the layouts operate on different data structures it makes sense
> to make the methods operate on those, and keep the boilerplate code
> including the XDR encoding/decoding in one single place.
> 
> Now how these pnfsd object layout drivers communicate with the fs I
> don't have an opinion on until we see the actual code, maybe we need a
> pnfs_<layout>_ops if it's complicated enough.

The original design this patchset builds on called for implementing the
layout type specifics as library code and let file systems supporting pnfs
implement the high level pnfs methods and use the library for encoding
and decoding layout-type specific XDR and use other helpers if needed.

You're calling for a "back-end layout driver" kind of layer that will serve
the layout type and will call into the file system using lower level methods.

>  For the files case that
> can just call into dlm directly currently as we have no other
> interesting cluster fs in tree it's a mood point.  For block it's simple
> enough that I'd just add it to export_ops, if not by that time we redo
> the current get_blocks mess in a way that we can simply piggyback it on
> that which would be even easier.
> 

On the same lines, I think that for now calling directly into exofs makes
the most sense as we have no other object based pnfs implementation.

>>> This way we alsod avoid the dependcy on nfsd in the filesystems that the
>>> cureent version introduces.

Yeah, I agree that this dependency can and should be taken care of.

>>
>> There is no "dependency on nfsd in the filesystems"
> 
> The patchset as pulled will created a depency on nfsd.ko from gfs2.ko
> 

yup, fs/nfsd/nfs4pnfsdlm.c exports pnfs_dlm_export_ops and implements
the respective methods.  This does not really belong to nfsd but rather
to the fs/dlm module.

Benny

>> The only dependency the FS has is an import of some library routines
>> at exportfs that take an abstract layout and device descriptions and encode
>> them into an XDR buffer. But the FS knows nothing of the XDR and the
>> NFSD is free to unload at any moment without forcing the FS to unload
>> first or at all.
>> This is actually tested, in fact I do this all the time when I want to
>> start fresh and have NFSD close all resources on the FS. 
> 
> That's not what happens with the file layout as posted, and it's not
> something I want to see happen every, btw.  In Linux we're all about
> proper abstractions, and letting a fs control all pnfs aspects directly
> instead of having common code is a receipe for tons of copy & pasted
> code full of different bugs if we ever get additional implementations of
> a layout.  Not that I really expect any in tree as all the other
> "interested partied" have shown to be leechers that just want to keep
> their filesystems out of tree and most of the time as illegal propritary
> modules anyway.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
