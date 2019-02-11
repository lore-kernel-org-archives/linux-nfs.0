Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1CCCC4151A
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 15:58:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 739E921B24
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 15:58:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730903AbfBKP6L (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 10:58:11 -0500
Received: from mx1.redhat.com ([209.132.183.28]:45432 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729994AbfBKP6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Feb 2019 10:58:11 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 672F42DD2A;
        Mon, 11 Feb 2019 15:58:10 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-123-64.rdu2.redhat.com [10.10.123.64])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4FA9619741;
        Mon, 11 Feb 2019 15:58:05 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id 395D81801AB; Mon, 11 Feb 2019 10:58:04 -0500 (EST)
Date:   Mon, 11 Feb 2019 10:58:04 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Jeff Layton <jlayton@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Shaohua Li <shli@fb.com>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/7] Eliminate delegation self-conflicts
Message-ID: <20190211155803.GA28714@parsley.fieldses.org>
References: <1549656647-25115-1-git-send-email-bfields@redhat.com>
 <bbc264481c2368f1e7a386cafb0cd5fba6af7ecf.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbc264481c2368f1e7a386cafb0cd5fba6af7ecf.camel@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 11 Feb 2019 15:58:10 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Feb 09, 2019 at 07:43:54AM -0500, Jeff Layton wrote:
> On Fri, 2019-02-08 at 15:10 -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > These patches allow NFSv4 clients holding delegations to keep them when
> > the operation that would break a delegation comes from the same client.
> > 
> > To do that, we somehow need to pass the identity of the
> > delegation-breaker down through the VFS.
> > 
> > This series uses the tgid, a solution suggested by Trond.  To do that we
> > need nfsd tasks to share the same tgid.  I do that by extending the
> > kthread code slightly to allow knfsd to run the kthreadd main loop in a
> > task of its own, and spawn its server threads off of that task.
...
> Nice work! I like the basic idea, the changes seem to be well-organized, 
> and the tgid semantics are clear and make sense.
> 
> Would this preclude us from moving to a workqueue-based model for knfsd
> later? It's likely to still be worth it, but it'd be good to understand
> the potential drawbacks.

I was wondering about that too, but I haven't looked into it yet.
Workqueues look a lot more complicated than kthreads.

--b.
