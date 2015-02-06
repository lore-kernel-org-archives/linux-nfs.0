Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918AbbBFPEu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Feb 2015 10:04:50 -0500
Date: Fri, 6 Feb 2015 10:04:36 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Julien Cristau <julien.cristau@logilab.fr>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, David Douard <david.douard@logilab.fr>
Subject: Re: nfs client stat() performance degradation
In-Reply-To: <20150113163618.GA17059@sh76.dev.logilab.fr>
Message-ID: <alpine.OSX.2.19.9992.1502060948480.480@planck.local>
References: <20150113163618.GA17059@sh76.dev.logilab.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Jan 2015, Julien Cristau wrote:

> Hi,
>
> we're experiencing some troubling performance issues with our nfs clients.  One
> of the symptoms is degraded performance of directory walks with hot caches and
> expired attribute caches: "find -ls" in the kernel tree goes from about 4s
> (cold caches) to 1.5s (hot vm caches) and then to 18s after actimeo.  Network
> traffic increases by about the same amount.  "echo 3 >
> /proc/sys/vm/drop_caches" brings back the initial performance (~4s), but so do
> writing 1 or 2.
>
> This was reported almost two years ago in https://bugs.debian.org/702477 but I
> don't know if this is a known issue upstream.  Seen on various kernel versions,
> up to 3.18.
>
> Is there anything we can do to track this down, or are there known workarounds
> for this?
>
> Thanks,
> Julien

Hi Julien,

I think that after the attribute cache times out, the client has to do a lot
of GETATTRs to revalidate inodes which is where you're getting slowed down.

When each directory is initially read READDIR is filling in the attribute
information and then caching the results of that READDIR in the page cache.
Then the attribute cache times out, the directory is revalidated (it hasn't
changed) and the contents of the directory are read from page cache, but
each directory entry's attributes are now also timed out and so the many
GETATTRs.

When you dump the page cache, it makes sense that the client goes back to
doing READDIRs, and your directory walk is faster.

Possibly we could invalidate directory inode pages whenever the attributes
time out, but I'm not sure what all the ramifications of that may be.

I also feel like this issue has already been discussed, but I'm not
immediately able to locate that discussion.

Ben
