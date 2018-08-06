Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731454AbeHFViP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Aug 2018 17:38:15 -0400
Date: Mon, 6 Aug 2018 15:27:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: xuhuan <xuhuan.fnst@cn.fujitsu.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: xfstest generci/465 failed under all versions of NFS
Message-ID: <20180806192743.GA9158@fieldses.org>
References: <ff080c90-e2e9-686f-9bcd-b6a4af8ac1a0@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ff080c90-e2e9-686f-9bcd-b6a4af8ac1a0@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 06, 2018 at 05:29:33PM +0800, xuhuan wrote:
> I test NFS in xfstest generic/465 useing kernel v4.18-rc6.
> I tested it with all version of nfs ,and all got failed.
> 
> This patch fixes a bug in the xfs filesystem.Prior to this patch,
> generic/465 is failed under the xfs file system.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ee70daaba82d70766d0723b743d9fdeb3b06102a
> 
> Now, under the xfs file system, generic/465 is passed, but when I use
> it to test NFS, while the server using the xfs file system, the test will still fail.
> I think it is a nfs's bug.I donnot know where is it.

generic/465 says "Test i_size is updated properly under dio read/write".
So I guess it's doing some direct IO that appends to a file and then a
stat to confirm that we get the new i_size?

If this isn't working when run on an NFS filesystem, then I think either
the client isn't asking the server for the new i_size, or maybe it's
asking but getting a bad response.  The bad response might have the old
i_size.  Or I wonder if the client would be confused if the server
failed to update the change attribute (i_version) for some reason?

Does this test fail when we export other filesystems?  Is the failure
new, or has it always failed?

--b.
