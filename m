Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34248 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752541AbdKIVQT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 16:16:19 -0500
Date: Thu, 9 Nov 2017 21:16:13 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171109211613.GE21978@ZenIV.linux.org.uk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk>
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 09, 2017 at 12:04:19PM -0800, Linus Torvalds wrote:

> That case has probably not gotten a huge amount of testing.  As Al
> points out, it can cause absolutely horrendous cache access pattern
> changes, but it might also be triggering some corruption in case
> there's a problem with the plugin, or with some piece of kernel code
> that gets confused by it.

I suspect that it might be an effect of randomize shite done both to
struct mount *AND* to struct vfsmount embedded into it.  With
pointers to embedded struct vfsmount kept around a lot, and container_of()
used to get from them to corresponding struct mount.

That smells like a combination of idiocy that might have never occured
to the authors of said gcc plugin.

On the other hand, triggered gcc bugs certainly do add randomness, so good
luck explaining to the security community that it's not a good idea...
