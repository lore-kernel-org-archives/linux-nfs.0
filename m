Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932890Ab1IIUDF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 16:03:05 -0400
Date: Fri, 9 Sep 2011 16:03:04 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
Message-ID: <20110909200304.GA32125@fieldses.org>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110909143605.57d54899@tlielax.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 09, 2011 at 02:36:05PM -0400, Jeff Layton wrote:
> I've been looking at replacing the current scheme that knfsd uses to
> track client_id4's (aka the v4recoverydir stuff), with an
> upcall/downcall scheme. Primarily this is to allow for more robust
> handling of clustered NFSv4 services.
> 
> In the process, I've been looking at the various upcall schemes we use
> to see which ones might be suitable to use in this effort. I've noticed
> that we have several upcalls that use rpc_pipefs, and that all of them
> seem to make assumptions that the userspace programs will align their
> message structs identically to how the kernel does.
> 
> For instance, here's the idmap one:
> 
> struct idmap_msg {
>         __u8  im_type;
>         __u8  im_conv;
>         char  im_name[IDMAP_NAMESZ];
>         __u32 im_id;
>         __u8  im_status;
> };

That's the "legacy" idmap code, right?

In which case we want to leave it alone if at all possible and move
people to the new idmapper.

--b.

> 
> Note that this struct does not have __attribute__((packed)), so the
> compiler is allowed to add padding between the fields as it sees fit.
> 
> If, for instance, someone were to build the userspace programs
> differently than the kernel (for instance x86_64 kernel with i686
> userspace), it's possible that the padding between them would be
> different. It's also possible that different compilers might align
> things differently here.
> 
> The blocklayout upcall is even more scary as the width of the status
> field is not explicit:
> 
> struct bl_dev_msg {
>         int status;
>         uint32_t major, minor;
> };
> 
> ...it's unlikely that the kernel and userspace would differ on the size
> of an int here, but it might be a good idea to go ahead and make that
> explicitly 32 bits in case we end up dealing with more exotic arches at
> some point in the future.
> 
> I'm not sure what we can really do about this at this point. Adding
> this attribute now would definitely be an kernel/userspace
> compatibility issue.
> 
> One possibility is to add padding between the fields that aligns with
> the current padding that the compiler adds and then make them "packed".
> That might make these structs arch-specific though since different
> arches probably pad these differently... :-/
> 
> Am I making mountains out of molehills here? Thoughts?
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
