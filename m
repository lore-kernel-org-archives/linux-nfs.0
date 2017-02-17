Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33632 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934271AbdBQVWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 16:22:00 -0500
Date: Fri, 17 Feb 2017 16:21:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about NFSv4.2 server-side copy implementation
Message-ID: <20170217212153.GM10894@fieldses.org>
References: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
 <20170217200253.GI10894@fieldses.org>
 <CAN-5tyGF8z=k6hk+Xbnh+_mWAiW_ywNnYR01YiOBVBRFzcyXUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGF8z=k6hk+Xbnh+_mWAiW_ywNnYR01YiOBVBRFzcyXUw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 17, 2017 at 04:10:45PM -0500, Olga Kornievskaia wrote:
> On Fri, Feb 17, 2017 at 3:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Feb 14, 2017 at 08:07:48PM +0000, Mora, Jorge wrote:
> >> I can understand failing with NFS4ERR_INVAL when the source offset is beyond the end of the file,
> >> but do you think failing with NFS4ERR_INVAL is too strict when the source offset plus the count is beyond the end of the file?
> >> What is the rationalization for failing on this specific instance?
> >> Why not return a short copy instead?
> >> Can the COPY return a count less than what it requested (a short copy)?
> >>
> >> As of right now, the implementation on the Linux server adheres to the spec
> >
> > That's weird, do you have network traces showing that, or is it possible
> > the EINVAL is happening on the client side?
> >
> > From a quick look at the server code I can't see where it would be
> > generating that EINVAL, but I haven't tested this case and I could be
> > overlooking something....
> >
> 
> I think the current upstream COPY does not fail with EINVAL. The new
> code that Jorge was testing does adhere to the spec and fails with
> EINVAL.
> 
> Bruce, it looks to me that current upstream CLONE in this situation
> will return EINVAL (I see that on the network trace since the client
> will first try to do CLONE and if it can't it'll do COPY).

OK, I see, in fs/read_write.c:vfs_clone_file_range(),

	if (pos_in + len > i_size_read(inode_in))
		return -EINVAL;

And since a copy can be implemented under the covers as a clone, we can
hit that case in copy too.

(Though vfs_copy_file_range calls ->clone_file_range directly instead of
calling vfs_clone_file_range, so it's up to individual filesystems
whether they EINVAL in that case--the one I checked (btrfs) did, and I
think it makes sense for clone as it's an all-or-nothing operation.)

So maybe we have to allow this EINVAL behavior on copy, but it still
looks wrong to me to require it.

--b.


> 
> But we are trying to get some consistency in errors.
> 
> 
> > --b.
> >
> >> but copy_file_range succeeds
> >>
> >> when it is called against the local file system, NFSv4.x or NFSv3.
> >> For the local file system, NFSv4.x or NFSv3 copy_file_range falls back to regular copy by
> >> reading from the source file and then writing to the destination file but I do believe the
> >> syscall should be consistent regardless of the underlying file system.
> >>
> >>
> >> --Jorge
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
