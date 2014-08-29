Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:57218 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaH2XBu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2014 19:01:50 -0400
Date: Sat, 30 Aug 2014 00:01:47 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tao Peng <tao.peng@primarydata.com>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140829230147.GD7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk>
 <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 29, 2014 at 05:47:58PM -0400, Trond Myklebust wrote:

> Note that the issue happens with NFSv4 or NFSv4.1 (not NFSv3).

That's what I'd been using for testing.

> Note that on my system, if I call 'umount' a second time after getting
> the 'device is busy' error, then it succeeds. It looks as if the first
> call to 'umount /mnt' causes the directory /mnt/export to clear,
> causing the second 'umount /mnt' to succeeed (unless I try to access
> /mnt/export again):

Now, that smells like a different bug - see if commit ab8f2c from -next
helps with that one.

Anyway, I think I see what's going on; moreover, I have a kinda-sorta
solution for the current tree, but it's not something that'll be fun
to backport and I'd prefer to look for alternative solutions before going
for that one.  Hopefully I'll have something postable by tomorrow morning...
