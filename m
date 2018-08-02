Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44502 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726192AbeHBCcU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 22:32:20 -0400
Date: Thu, 2 Aug 2018 01:43:48 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Mark Fasheh <mfasheh@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] nfs: check for NULL vfsmount in nfs_getattr
Message-ID: <20180802004347.GV30522@ZenIV.linux.org.uk>
References: <20180731211045.5671-1-mfasheh@suse.de>
 <20180731211045.5671-3-mfasheh@suse.de>
 <20180731221605.GK30522@ZenIV.linux.org.uk>
 <20180731225157.GA20761@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180731225157.GA20761@wotan.suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2018 at 10:51:57PM +0000, Mark Fasheh wrote:
> Hi Al,
> 
> On Tue, Jul 31, 2018 at 11:16:05PM +0100, Al Viro wrote:
> > On Tue, Jul 31, 2018 at 02:10:43PM -0700, Mark Fasheh wrote:
> > > ->getattr from inside the kernel won't always have a vfsmount, check for
> > > this.
> > 
> > Really?  Where would that happen?
> 
> It happens in my first patch. FWIW, I'm not tied to that particular bit of
> code, or even this (latest) approach. I would actually very much appreciate
> your input into how we might fix the problem we have where we are sometimes
> not exporting a correct ino/dev pair to user space.

Which callers would those be?  I don't see anything in your series that
wouldn't have vfsmount at hand...

> I have a good break-down of the problem and possible solutions here:
> 
> https://www.spinics.net/lists/linux-fsdevel/msg128003.html

btrfs pulling odd crap with device numbers is a problem, but this is far from
the most obvious unpleasantness caused by that - e.g. userland code expecting
that unequal st_dev for directory and subdirectory means that we have
a mountpoint there.  Or assuming it can compare that to st_dev of mountpoints
(or, indeed, the values in /proc/self/mountinfo) to find which fs it's on...

/proc/*/maps is unfortunate, but it does contain the pathnames, doesn't it?
What _real_ problems are there - the ones where we don't have a saner solution?
Note that /proc/locks is (a) FPOS interface and (b) unsuitable for your
approach anyway.
