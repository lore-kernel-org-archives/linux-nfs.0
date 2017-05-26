Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38510 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764497AbdEZPJ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 11:09:56 -0400
Date: Fri, 26 May 2017 11:09:56 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: hch <hch@lst.de>, Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        virtualization@lists.linux-foundation.org
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170526150956.GB4593@fieldses.org>
References: <20170512161701.22468-1-hch@lst.de>
 <1494620040.19467.1.camel@primarydata.com>
 <20170513072557.GA14602@lst.de>
 <1494691819.31377.1.camel@primarydata.com>
 <20170515152134.GC24547@fieldses.org>
 <20170515154450.GA18630@lst.de>
 <20170523081159.GA19216@lst.de>
 <20170523122334.GA4298@fieldses.org>
 <20170526150839.GA4593@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170526150839.GA4593@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Probably should have cc'd virtualization@lists.linux-foundation.org too.

On Fri, May 26, 2017 at 11:08:39AM -0400, bfields@fieldses.org wrote:
> On Tue, May 23, 2017 at 08:23:34AM -0400, bfields@fieldses.org wrote:
> > Unfortunately I can't get anything through testing.  It's not your
> > patches, it's something in -rc1.  My server VM stops responding to
> > any network traffic randomly in the middle of a run.  If I log in from a
> > serial console, I see the interface is up and everything looks OK.  I
> > haven't had the chance to do much more, and I'm not sure where to
> > start....  I started a git-bisect attempt, but there are several
> > unrelated problems, and I'm not sure this one is 100% reproduceable.
> 
> It looks like it may be due to something pulled in with virtio updates.
> I've reproduced the problem on c8b0d7290657 "s390/virtio: change
> maintainership" but not on v4.11.  Are there any known issues with those
> commits?
> 
> I've just been doing this long-running bisect while working on other
> stuff.  My reproducer (basically just running a bunch of NFS
> connectathon tests over a variety of protocol versions and security
> flavors) doesn't hit the bug reliably, and I've had to restart a couple
> times probably due to false negatives.  But this looks pretty promising,
> and there's only 17 commits in that range, so I'll keep bisecting.
> 
> --b.
