Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:58491 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbaJXO3m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2014 10:29:42 -0400
Date: Fri, 24 Oct 2014 16:29:39 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
Message-ID: <20141024142939.GA22472@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de> <1411740170-18611-2-git-send-email-hch@lst.de> <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com> <20140926154843.GA22675@lst.de> <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 12:21:06PM -0400, Trond Myklebust wrote:
> > On Fri, Sep 26, 2014 at 10:29:34AM -0400, Trond Myklebust wrote:
> >> It worries me that we're putting a mutex directly in the writeback
> >> path. For small arrays, it might be acceptable, but what if you have a
> >> block device with 1000s of disks on the back end?
> >>
> >> Is there no better way to fix this issue?
> >
> > Not without getting rid of the rpc_pipefs interface.  That is on my
> > very long term TODO list, but it will require new userspace support.
> 
> Why is that? rpc_pipefs was designed to be message based, so it should
> work quite well in a multi-threaded environment. We certainly don't
> use mutexes around the gssd up/downcall, and the only reason for the
> mutex in idmapd is to deal with the keyring upcall.

Turns out we can't do anything like that with the existing blkmapd
ABI.  The other callers that support concurrency have some sort
of uniqueue identifier embedded in their messages both on the upcall
and the downcall, so that the kernel can find the right structure
on the downcall side.

Because of that I'd like to request inclusion of this patch with a Cc
to stable for 3.17.
