Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:53895 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbaKEIav (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 03:30:51 -0500
Date: Wed, 5 Nov 2014 09:30:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
Message-ID: <20141105083048.GA26612@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de> <1411740170-18611-2-git-send-email-hch@lst.de> <CAHQdGtTg8Tc8bRqbezW-ZWrcTJdG233uRTrqQMP5CvxAcjW9Fg@mail.gmail.com> <20140926154843.GA22675@lst.de> <CAHQdGtRYN_L4ONFU5-GW3=kJ1oz5HS_7kmsn=GWCCGTgBODQAA@mail.gmail.com> <20141024142939.GA22472@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141024142939.GA22472@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2014 at 04:29:39PM +0200, Christoph Hellwig wrote:
> Turns out we can't do anything like that with the existing blkmapd
> ABI.  The other callers that support concurrency have some sort
> of uniqueue identifier embedded in their messages both on the upcall
> and the downcall, so that the kernel can find the right structure
> on the downcall side.
> 
> Because of that I'd like to request inclusion of this patch with a Cc
> to stable for 3.17.

ping?  This is an easily expoitable oops, so I'd really like to see the/a
fix in 3.18-rc and 3.17-stable.

Thanks,
	Christoph
