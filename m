Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39068 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932250AbdCFTJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Mar 2017 14:09:37 -0500
Date: Mon, 6 Mar 2017 14:09:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] Don't copy beyond the end of the file
Message-ID: <20170306190936.GA2294@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
 <20170303213230.GF13877@fieldses.org>
 <B3F80DA0-B4F8-4628-88C5-E5C047620F17@netapp.com>
 <20170304021008.GB21609@fieldses.org>
 <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 06, 2017 at 11:27:23AM -0500, Olga Kornievskaia wrote:
> 
> > On Mar 3, 2017, at 9:10 PM, J. Bruce Fields <bfields@fieldses.org>
> > wrote:
> > 
> > On Fri, Mar 03, 2017 at 05:46:05PM -0500, Olga Kornievskaia wrote:
> >> 
> >>> On Mar 3, 2017, at 4:32 PM, J. Bruce Fields <bfields@fieldses.org>
> >>> wrote:
> >>> 
> >>> On Fri, Mar 03, 2017 at 04:08:19PM -0500, Olga Kornievskaia wrote:
> >>>> 
> >>>>> On Mar 3, 2017, at 3:47 PM, J. Bruce Fields
> >>>>> <bfields@fieldses.org> wrote:
> >>>>> 
> >>>>> On Thu, Mar 02, 2017 at 08:22:21AM -0800, Christoph Hellwig
> >>>>> wrote:
> >>>>>> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia
> >>>>>> wrote:
> >>>>>>> +	if (pos_in >= i_size_read(inode_in)) +		return
> >>>>>>> -EINVAL;
> >>>>>> 
> >>>>>> That's not how the syscall is supposed to work, we'd rather do
> >>>>>> a short read^^^^^copy.
> >>>>> 
> >>>>> That's what I think too, but then is COPY(2) wrong?:
> >>>>> 
> >>>>> 	EINVAL Requested  range  extends beyond the end of the
> >>>>> 	source file; or the flags argument is not 0.
> >>>>> 
> >>>>> Also, copy_file_range can be implemented by ->clone_file_range,
> >>>>> where these kinds of checks make more sense, I think; e.g. from
> >>>>> btrfs:
> >>>>> 
> >>>>> 	ret = -EINVAL; if (off + len > src->i_size || off + len
> >>>>> 	< off) goto out_unlock;
> >>>>> 
> >>>>> Well, so the caller just has to be prepared for either behavior,
> >>>>> I guess, but that may make it more complicated to use.
> >>>>> 
> >>>> 
> >>>> I’m still rather very confused again by the comment and what it
> >>>> is proposing.
> >>>> 
> >>>> There are two checks to consider for the validity of the
> >>>> arguments
> >>>> 
> >>>> 1. If the offset of the source file is beyond the end of the
> >>>> source file.  2. If the offset + len is beyond the end of the
> >>>> file.
> >>>> 
> >>>> I read that the man page is talking about #2.  This is actually
> >>>> what the NFSv4.2 spec required for the COPY too but we’ve been
> >>>> discussing that it should be a short read instead.
> >>>> 
> >>>> This patch address is to address case #1. As far as I can tell it
> >>>> applies to all file systems.
> >>>> 
> >>>> Are you suggesting that the checks for the validity of the
> >>>> arguments do not belong in VFS but instead should be in each of
> >>>> the underlying file systems?
> >>>> 
> >>>> Not all vfs_copy_file_range() are implemented via
> >>>> clone_file_range(). At least I hope that “inter” NFSv4.2 COPY
> >>>> will also use vfs_file_copy_range() and it would not be calling
> >>>> clone().
> >>> 
> >>> I think it'd be acceptable for copy_file_range() to just return 0
> >>> even in your case 1.  I believe that's what ordinary read and
> >>> pread does.
> >>> 
> >>> You probably can't perform it atomically with the copy, so it's
> >>> possible that the size will change right after you check it.
> >>> 
> >>> I don't see a benefit to the check.
> >> 
> > 
> >> In read() you don’t specify the offset from which to read. It is
> >> read from the current file descriptor offset. I don’t find the
> >> comparison equal. 
> >> 
> >> It’s it more fair to compare it to lseek() which does return EINVAL
> >> if you specify position beyond the end of the file. 
> > 
> > Or pread(), which takes an offset.
> > 
> > But read() can read at an offset at the end of file, or even past
> > that (if the file was truncated), and I believe it just returns 0 in
> > those cases.
> > 
> 
> I don’t see copy_file_range() specifying that 0 means end of the file.
> Are you arguing to add that meaning to the function call?

Yes.

> I guess in
> that case we’d need to take extra care to never return 0bytes to the
> client as a “partial” copy (say due to server rebooting).

Right.

> Unless changed, NFS4.2 mandates the two checks that I’ve specified. I
> can add the checks in the NFS implementation itself. However, we
> thought at least this check belonged in the VFS layer. I’m really not
> super attached to getting into VFS. Actually the 2nd check is
> something that copy_file_range() man pages say should return EINVAL
> but the VFS code doesn’t enforce it. 

Please leave those checks out.  Let's try to fix the spec.

--b.
