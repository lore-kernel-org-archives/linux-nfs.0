Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2C5FC10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:35:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ADB3C21925
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:35:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726633AbfBOQfO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:35:14 -0500
Received: from fieldses.org ([173.255.197.46]:39360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726137AbfBOQfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:35:14 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 11D521CE7; Fri, 15 Feb 2019 11:35:14 -0500 (EST)
Date:   Fri, 15 Feb 2019 11:35:14 -0500
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/7] Eliminate delegation self-conflicts
Message-ID: <20190215163514.GA22354@fieldses.org>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
 <bbc264481c2368f1e7a386cafb0cd5fba6af7ecf.camel@redhat.com>
 <20190211155803.GA28714@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211155803.GA28714@parsley.fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 11, 2019 at 10:58:04AM -0500, J. Bruce Fields wrote:
> On Sat, Feb 09, 2019 at 07:43:54AM -0500, Jeff Layton wrote:
> > On Fri, 2019-02-08 at 15:10 -0500, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > These patches allow NFSv4 clients holding delegations to keep them when
> > > the operation that would break a delegation comes from the same client.
> > > 
> > > To do that, we somehow need to pass the identity of the
> > > delegation-breaker down through the VFS.
> > > 
> > > This series uses the tgid, a solution suggested by Trond.  To do that we
> > > need nfsd tasks to share the same tgid.  I do that by extending the
> > > kthread code slightly to allow knfsd to run the kthreadd main loop in a
> > > task of its own, and spawn its server threads off of that task.
> ...
> > Nice work! I like the basic idea, the changes seem to be well-organized, 
> > and the tgid semantics are clear and make sense.
> > 
> > Would this preclude us from moving to a workqueue-based model for knfsd
> > later? It's likely to still be worth it, but it'd be good to understand
> > the potential drawbacks.
> 
> I was wondering about that too, but I haven't looked into it yet.
> Workqueues look a lot more complicated than kthreads.

I spent some time staring, and...  I still don't really understand the
workqueue code.  But if this kthread_group[*] code is acceptable than I
can't see why it shouldn't be possible to create a workqueue whose work
items are all handled by threads spawned form the same kthread_group.

--b.

[*] Open to suggestions of better names.
