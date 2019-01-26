Return-Path: <SRS0=byNy=QC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24DA2C282C7
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 22:36:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EA25E2184C
	for <linux-nfs@archiver.kernel.org>; Sat, 26 Jan 2019 22:36:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726373AbfAZWgq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 26 Jan 2019 17:36:46 -0500
Received: from fieldses.org ([173.255.197.46]:50998 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726367AbfAZWgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 26 Jan 2019 17:36:45 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id D4EE56D9; Sat, 26 Jan 2019 17:36:44 -0500 (EST)
Date:   Sat, 26 Jan 2019 17:36:44 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix error return values for
 nfsd4_clone_file_range()
Message-ID: <20190126223644.GA24528@fieldses.org>
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
 <20190125004658.GB3953@fieldses.org>
 <698446e18a6718ee1ced06ecfd06e2de802fa16e.camel@gmail.com>
 <20190125163218.GA2752@fieldses.org>
 <CAN-5tyEZhVEMSjxbWfGoODb6eAmO7VJLjYkMv2HwUyXKHjyyWw@mail.gmail.com>
 <20190125201037.GA5173@fieldses.org>
 <20190125201551.GB5173@fieldses.org>
 <20190125205726.GA19328@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125205726.GA19328@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 25, 2019 at 12:57:26PM -0800, Darrick J. Wong wrote:
> On Fri, Jan 25, 2019 at 03:15:51PM -0500, J. Bruce Fields wrote:
> > On Fri, Jan 25, 2019 at 03:10:37PM -0500, J. Bruce Fields wrote:
> > > Yeah.  I was assuming it could happen in the case you ask to clone
> > > beyond the end of the source file.  But looking at the code, there's a
> > > check for that case in generic_remap_checks() before doing the clone,
> > > and while holding a write lock on i_rwsem (I assume that's enough to
> > > hold the file size constant).  At least that's true in the cases (btrfs
> > > & xfs) that I checked.
> > > 
> > > So, I don't know, maybe that check is just dead code.
> > 
> > In the xfs case it looks like the main work of the clone is done in
> > xfs_reflink_remap_blocks(), where there's a loop like:
> > 
> > 	while (len) {
> > 		... mysterious code that clones range_len worth of
> > 		    extents?
> > 		if (fatal_signal_pending(current)) {
> > 			error =-EINTR;
> > 			break;
> > 		}
> > 		...
> > 		len -= range_len;
> > 		remapped_len += range_len;
> > 	}
> > 
> > And then it ends up returning remapped_len if it's positive.
> 
> Hmm?  In xfs_reflink_remap_blocks, *remapped (an out parameter) is set
> to remapped_len just prior to returning whatever error is.  The caller
> (xfs_file_remap_range) can see how many bytes were remapped, as well as
> any error that might have cut short the remapping process...
> 
> > So it looks to me like if you do a big clone on xfs and kill the
> > process, it can clone part of the range, return the amount cloned, and
> > then the ioctl code will throw away that amount and just return EINVAL,
> 
> ...and so xfs_file_remap_range will return the number of bytes remapped
> before it returns any error codes.  This was done so that
> copy_file_range can call remap_file_range and report a short but
> otherwise successful copy.
> 
> Yes, it's sort of dumb that we pass the "bytes remapped" information all
> the way up the call stack only to have the clonerange ioctl spit back
> EINVAL on a short remap, but we're stuck with that (poorly thought out)
> artifact of btrfs.

Is there any real reason not to just remove it?  It looks to me like a
no-op in the btrfs case.

> Note that XFS can return cloned < count if (for example) it runs out of
> space trying to expand the extent map btree to add more extents.

Makes sense.  Uh, my fatal signal case was dumb, wasn't it, nobody's
going to see the return value from the system call then anyway.

Still, returning -EINVAL after some data was actually copied seems like
the kind of thing that could cause real bugs.

> > with the result that the application thinks the operation failed
> > completely actually it cloned a bunch of data.
> 
> (Yes, the ioctl is dumb; I would say that programs should use
> copy_file_range instead as a less bad interface, but the splice copy
> fallback is ...  yuck.)

I agree.

--b.
