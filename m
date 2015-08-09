Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33677 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932916AbbHILLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 07:11:40 -0400
Received: by ykaz130 with SMTP id z130so12594133yka.0
        for <linux-nfs@vger.kernel.org>; Sun, 09 Aug 2015 04:11:39 -0700 (PDT)
Date: Sun, 9 Aug 2015 07:11:37 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150809071137.28ca8f19@tlielax.poochiereds.net>
In-Reply-To: <20150809071438.GC9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
	<20150809071438.GC9772@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 9 Aug 2015 00:14:38 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Aug 05, 2015 at 05:13:21PM -0400, Jeff Layton wrote:
> > Currently, nfsd uses a singlethread workqueue for this, but that's not
> > necessary. If we have multiple namespaces, then there's no need to
> > serialize the laundromat runs since they are only requeued at the end of
> > the work itself.
> > 
> > Also, create_singlethread_workqueue adds the WQ_MEM_RECLAIM flag, which
> > doesn't really seem to be necessary. The laundromat jobs are always
> > kicked off via a timer, and not from memory reclaim paths. There's no
> > need for a rescuer thread.
> 
> Why would you change it to an unbound WQ?  I'd really prefer to split
> the change of workqueue semantics and making it globall available, too.

create_singlethread_workqueue already makes an unbound workqueue. This
patch just lifts the "max_active" value to the default, and removes the
WQ_MEM_RECLAIM flag.

We certainly could turn this into a bound workqueue, but given the sort
of job that the laundromat runs I'm not sure we'd benefit much from the
locality.

...and sure, I can turn this into two patches if you'd prefer.

-- 
Jeff Layton <jlayton@poochiereds.net>
