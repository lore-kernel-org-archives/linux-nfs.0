Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37638 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1731637AbeHAAec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 20:34:32 -0400
Date: Tue, 31 Jul 2018 22:51:57 +0000
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] nfs: check for NULL vfsmount in nfs_getattr
Message-ID: <20180731225157.GA20761@wotan.suse.de>
Reply-To: Mark Fasheh <mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
 <20180731211045.5671-3-mfasheh@suse.de>
 <20180731221605.GK30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180731221605.GK30522@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

On Tue, Jul 31, 2018 at 11:16:05PM +0100, Al Viro wrote:
> On Tue, Jul 31, 2018 at 02:10:43PM -0700, Mark Fasheh wrote:
> > ->getattr from inside the kernel won't always have a vfsmount, check for
> > this.
> 
> Really?  Where would that happen?

It happens in my first patch. FWIW, I'm not tied to that particular bit of
code, or even this (latest) approach. I would actually very much appreciate
your input into how we might fix the problem we have where we are sometimes
not exporting a correct ino/dev pair to user space.

I have a good break-down of the problem and possible solutions here:

https://www.spinics.net/lists/linux-fsdevel/msg128003.html

Thanks,
	--Mark
