Return-Path: <SRS0=ELWp=WI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA3D5C433FF
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Aug 2019 20:00:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 616A120673
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Aug 2019 20:00:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726877AbfHLUAU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Aug 2019 16:00:20 -0400
Received: from mx1.redhat.com ([209.132.183.28]:42592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726200AbfHLUAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Aug 2019 16:00:20 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 75BD5315C036;
        Mon, 12 Aug 2019 20:00:20 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-122-197.rdu2.redhat.com [10.10.122.197])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 507951001281;
        Mon, 12 Aug 2019 20:00:20 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id A51E8180A60; Mon, 12 Aug 2019 16:00:19 -0400 (EDT)
Date:   Mon, 12 Aug 2019 16:00:19 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 5/9] NFSD add COPY_NOTIFY operation
Message-ID: <20190812200019.GB29812@parsley.fieldses.org>
References: <20190808201848.36640-1-olga.kornievskaia@gmail.com>
 <20190808201848.36640-6-olga.kornievskaia@gmail.com>
 <CAN-5tyF6ZMf_jiKycK1rk9v7xATDb=j_e5d0QBp9LOgdvn-utA@mail.gmail.com>
 <CAN-5tyEyvjJB+4_bKZmEYhv2KrVvk7dDvF27i6mx4naDt33Nww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyEyvjJB+4_bKZmEYhv2KrVvk7dDvF27i6mx4naDt33Nww@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 12 Aug 2019 20:00:20 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Aug 12, 2019 at 03:16:47PM -0400, Olga Kornievskaia wrote:
> On Mon, Aug 12, 2019 at 12:19 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> > While this passes my testing, in theory this allows for the race that
> > we get the copy notify size but then offload_cancel arrive and change
> > the value. Then refcount_sub_and test_check would have an incorrect
> > value (can subtract larger than an actual reference count). I have no
> > solution for that as there is no refcount_sub_and_lock() that will
> > allow to decrement by a multiple under a lock. Thoughts?
> 
> I tried not to use the client's cl_lock but instead use a specific
> lock to protect the copy notifies stateid on the stateid list. But
> since stateid's reference counter (sc_count) is protected by it, I
> think by getting rid of the special lock and using cl_lock will solve
> the problem of coordinating access between the sc_count and the
> copy_notify stateid list. Are the any problems with using such a big
> lock?

Probably not.  But it can be confusing when a single lock is used for
several different things.  A comment explaining why you need it might
help.

--b.
