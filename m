Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:60446 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaHaEJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Aug 2014 00:09:13 -0400
Date: Sun, 31 Aug 2014 05:09:10 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140831040910.GH7996@ZenIV.linux.org.uk>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk>
 <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk>
 <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
 <20140830173638.GE7996@ZenIV.linux.org.uk>
 <20140830232755.GG7996@ZenIV.linux.org.uk>
 <CAKVebiV8erTbK6ZA1g2X+xsKRBG2n61XBoqc04NvzSGTZRhTgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiV8erTbK6ZA1g2X+xsKRBG2n61XBoqc04NvzSGTZRhTgw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 31, 2014 at 08:31:47AM +0800, Peng Tao wrote:
> On Sun, Aug 31, 2014 at 7:27 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >         Could you check if vfs.git#for-linus fixes that crap?
> The related commits are the top two of vfs.git#for-linus, right? I
> cherry-picked them to 3.14.15 and they fixed the bug instantly. Thank
> you for the quick fix!

Folks, could somebody put together an xfstests (or LTP, for that matter)
patch adding that testcase?  Which regression suite is normally used
for NFS work, BTW?  It's not, strictly speaking, an NFS-specific bug
(you can trigger the same thing on AFS and CIFS as well), but NFS is
by far the most common of those three, so...
