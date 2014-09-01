Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:43183 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752433AbaIAXw3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Sep 2014 19:52:29 -0400
Date: Tue, 2 Sep 2014 09:52:26 +1000
From: Dave Chinner <david@fromorbit.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: VFS regression: commit aba809cf0944 breaks MNT_SHRINKABLE
 automounted partitions
Message-ID: <20140901235226.GJ26465@dastard>
References: <CAHQdGtT4kbPqQvD_fu7c_5_CqK8FCpA5mJsVdh=KxoE9_vXRzw@mail.gmail.com>
 <20140829205817.GB7996@ZenIV.linux.org.uk>
 <CAHQdGtRBqmsfeVVysTnTEELHuwiPwvsyTHtoRAsfSS0aSyCbfQ@mail.gmail.com>
 <20140829230147.GD7996@ZenIV.linux.org.uk>
 <CAKVebiWBU3du650yeTMfaFuLr=WLUBc2RukFGyBF6Qgxd6zA8Q@mail.gmail.com>
 <20140830173638.GE7996@ZenIV.linux.org.uk>
 <20140830232755.GG7996@ZenIV.linux.org.uk>
 <CAKVebiV8erTbK6ZA1g2X+xsKRBG2n61XBoqc04NvzSGTZRhTgw@mail.gmail.com>
 <20140831040910.GH7996@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140831040910.GH7996@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 31, 2014 at 05:09:10AM +0100, Al Viro wrote:
> On Sun, Aug 31, 2014 at 08:31:47AM +0800, Peng Tao wrote:
> > On Sun, Aug 31, 2014 at 7:27 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > >         Could you check if vfs.git#for-linus fixes that crap?
> > The related commits are the top two of vfs.git#for-linus, right? I
> > cherry-picked them to 3.14.15 and they fixed the bug instantly. Thank
> > you for the quick fix!
> 
> Folks, could somebody put together an xfstests (or LTP, for that matter)
> patch adding that testcase?  Which regression suite is normally used
> for NFS work, BTW?  It's not, strictly speaking, an NFS-specific bug
> (you can trigger the same thing on AFS and CIFS as well), but NFS is
> by far the most common of those three, so...

You can use xfstests to test NFS from the client side, and there are
patches pending to add CIFS client support to xfstests as well.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
