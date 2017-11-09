Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60186 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbdKITjD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 14:39:03 -0500
Date: Thu, 9 Nov 2017 19:38:59 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Patrick McLean <chutzpah@gentoo.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171109193859.GC21978@ZenIV.linux.org.uk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <8fc5311b-fc56-1c19-8f63-0c509d3dd4ad@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8fc5311b-fc56-1c19-8f63-0c509d3dd4ad@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 09, 2017 at 11:34:19AM -0800, Patrick McLean wrote:

> > In particular, there are *no* nfsd changes in that 4.13.8..4.13.11
> > range. There is a bunch of xfs changes, though. What's the underlying
> > filesystem that you are exporting?
> 
> It's an ext4 filesystem.

Had there been toolchain changes around the same period?
