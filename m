Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E75EC10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:41:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D3DB320883
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:41:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726558AbfDHQlL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 12:41:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:48418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726383AbfDHQlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 12:41:11 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 341B530821C0;
        Mon,  8 Apr 2019 16:41:11 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-116-233.phx2.redhat.com [10.3.116.233])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F191F665C4;
        Mon,  8 Apr 2019 16:41:10 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id D80B7180A4E; Mon,  8 Apr 2019 12:41:09 -0400 (EDT)
Date:   Mon, 8 Apr 2019 12:41:09 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Don't release the callback slot unless it was
 actually held
Message-ID: <20190408164109.GA18799@parsley.fieldses.org>
References: <20190405155437.5545-1-trond.myklebust@hammerspace.com>
 <4bf043aa23b4230bf41fbcd5611b3baff4977f1d.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4bf043aa23b4230bf41fbcd5611b3baff4977f1d.camel@hammerspace.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 08 Apr 2019 16:41:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 08, 2019 at 03:20:48PM +0000, Trond Myklebust wrote:
> On Fri, 2019-04-05 at 08:54 -0700, Trond Myklebust wrote:
> > If there are multiple callbacks queued, waiting for the callback
> > slot when the callback gets shut down, then they all currently
> > end up acting as if they hold the slot, and call
> > nfsd4_cb_sequence_done() resulting in interesting side-effects.
> > 
> > In addition, the 'retry_nowait' path in nfsd4_cb_sequence_done()
> > causes a loop back to nfsd4_cb_prepare() without first freeing the
> > slot, which causes a deadlock when nfsd41_cb_get_slot() gets called
> > a second time.
> > 
> > This patch therefore adds a boolean to track whether or not the
> > callback did pick up the slot, so that it can do the right thing
> > in these 2 cases.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> > v2: try to restart the callback if we hit nfsd4_cb_sequence_done()
> >     without a slot.
> > 
> > 
> 
> Hi Bruce,
> 
> Should this patch perhaps be considered for stable? The callback slot
> leak is permanent (or at least for the lifetime of the nfs4_client).

Makes sense to me; I'll queue it up for 5.1 and stable.

What were the original symptoms that prompted this?

--b.
