Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D13C67863
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 04:37:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB33C2083A
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 04:37:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB33C2083A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727061AbeJVMyg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 08:54:36 -0400
Received: from ipmail03.adl2.internode.on.net ([150.101.137.141]:32608 "EHLO
        ipmail03.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726784AbeJVMyg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 08:54:36 -0400
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 22 Oct 2018 15:07:42 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gERyH-0002MU-KY; Mon, 22 Oct 2018 15:37:41 +1100
Date:   Mon, 22 Oct 2018 15:37:41 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Message-ID: <20181022043741.GX6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022022112.GW6311@dastard>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 01:21:12PM +1100, Dave Chinner wrote:
> On Sun, Oct 21, 2018 at 09:15:03AM -0700, Darrick J. Wong wrote:
> > Hi all,
> > 
> > Dave, Eric, and I have been chasing a stale data exposure bug in the XFS
> > reflink implementation, and tracked it down to reflink forgetting to do
> > some of the file-extending activities that must happen for regular
> > writes.
> > 
> > We then started auditing the clone, dedupe, and copyfile code and
> > realized that from a file contents perspective, clonerange isn't any
> > different from a regular file write.  Unfortunately, we also noticed
> > that *unlike* a regular write, clonerange skips a ton of overflow
> > checks, such as validating the ranges against s_maxbytes, MAX_NON_LFS,
> > and RLIMIT_FSIZE.  We also observed that cloning into a file did not
> > strip security privileges (suid, capabilities) like a regular write
> > would.  I also noticed that xfs and ocfs2 need to dump the page cache
> > before remapping blocks, not after.
> > 
> > In fixing the range checking problems I also realized that both dedupe
> > and copyfile tell userspace how much of the requested operation was
> > acted upon.  Since the range validation can shorten a clone request (or
> > we can ENOSPC midway through), we might as well plumb the short
> > operation reporting back through the VFS indirection code to userspace.
> > I added a few more cleanups to the xfs code per reviewer suggestions.
> > 
> > So, here's the whole giant pile of patches[1] that fix all the problems.
> > This branch is against current upstream (4.19-rc8).  The patch
> > "generic: test reflink side effects" recently sent to fstests exercises
> > the fixes in this series.  Tests are in [2].
> 
> Ok, so now that all the patches (other than the ocfs2 bits) have been
> reviewed, how do we want to merge this? I can take it through the
> XFS tree given that there is a bit of XFS changes that needs to be
> co-ordinated with it, or should it go through some other tree?

Ok, this is a bit of a mess. the patches do not merge cleanly to a
4.19-rc1 base kernel because of all the changes to
include/linux/fs.h that have hit the tree after this. There's also
failures against Documentation/filesystems/fs.h

IOWs, it's not going to get merged through the main XFS tree because
I don't have the patience to resolve all the patch application
failures, then when it comes to merge make sure all the merge
failures end up being resolved correctly.

So if I take it through the XFS tree, it will being a standalone
branch based on 4.19-rc8 and won't hit linux-next until after the
first XFS merge when I can rebase the for-next branch...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
