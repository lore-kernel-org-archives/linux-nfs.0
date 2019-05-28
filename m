Return-Path: <SRS0=hGXo=T4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6CA9C04AB6
	for <linux-nfs@archiver.kernel.org>; Tue, 28 May 2019 15:13:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B11632075B
	for <linux-nfs@archiver.kernel.org>; Tue, 28 May 2019 15:13:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727854AbfE1PNc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 28 May 2019 11:13:32 -0400
Received: from fieldses.org ([173.255.197.46]:38270 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726826AbfE1PNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 May 2019 11:13:32 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 465721C21; Tue, 28 May 2019 11:13:31 -0400 (EDT)
Date:   Tue, 28 May 2019 11:13:31 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     YueHaibing <yuehaibing@huawei.com>, jlayton@kernel.org,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH -next] lockd: Make two symbols static
Message-ID: <20190528151331.GA29554@fieldses.org>
References: <20190528090652.13288-1-yuehaibing@huawei.com>
 <97D052EC-1F07-4210-81CC-7E0085C095BD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97D052EC-1F07-4210-81CC-7E0085C095BD@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, May 28, 2019 at 06:49:13AM -0400, Benjamin Coddington wrote:
> Maintainers, what's the best thing to do here: fold these into
> another patch version and post it (add attribution)?  Add it as
> another patch at the end of the series?

Either would be fine.  Yeah, if it was folded in then we'd add a line
like

	[hulkci@huawei.com: make symbols static to fix sparse warnings]

But I'll probably just add it on to the end for now.  No need for you to
do anything.

> I have learned my lesson: add sparse to my workflow.

I dunno, I wonder if we're better off just leaving it to this CI bot.
It seems like a more efficient use of time overall than making every
contributor run it.

--b.

> Ben
> 
> On 28 May 2019, at 5:06, YueHaibing wrote:
> 
> >Fix sparse warnings:
> >
> >fs/lockd/clntproc.c:57:6: warning: symbol 'nlmclnt_put_lockowner'
> >was not declared. Should it be static?
> >fs/lockd/svclock.c:409:35: warning: symbol 'nlmsvc_lock_ops' was
> >not declared. Should it be static?
> >
> >Reported-by: Hulk Robot <hulkci@huawei.com>
> >Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> >---
> > fs/lockd/clntproc.c | 2 +-
> > fs/lockd/svclock.c  | 2 +-
> > 2 files changed, 2 insertions(+), 2 deletions(-)
> >
> >diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> >index 0ff8ad4..b11f2af 100644
> >--- a/fs/lockd/clntproc.c
> >+++ b/fs/lockd/clntproc.c
> >@@ -54,7 +54,7 @@ nlmclnt_get_lockowner(struct nlm_lockowner
> >*lockowner)
> > 	return lockowner;
> > }
> >
> >-void nlmclnt_put_lockowner(struct nlm_lockowner *lockowner)
> >+static void nlmclnt_put_lockowner(struct nlm_lockowner *lockowner)
> > {
> > 	if (!refcount_dec_and_lock(&lockowner->count,
> >&lockowner->host->h_lock))
> > 		return;
> >diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> >index 5f9f19b..61d3cc2 100644
> >--- a/fs/lockd/svclock.c
> >+++ b/fs/lockd/svclock.c
> >@@ -406,7 +406,7 @@ static void
> >nlmsvc_locks_release_private(struct file_lock *fl)
> > 	nlmsvc_put_lockowner((struct nlm_lockowner *)fl->fl_owner);
> > }
> >
> >-const struct file_lock_operations nlmsvc_lock_ops = {
> >+static const struct file_lock_operations nlmsvc_lock_ops = {
> > 	.fl_copy_lock = nlmsvc_locks_copy_lock,
> > 	.fl_release_private = nlmsvc_locks_release_private,
> > };
> >-- 
> >2.7.4
