Return-Path: <SRS0=WqcA=WP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88319C3A5A0
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 15:11:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 64BA220651
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 15:11:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725536AbfHSPLx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Aug 2019 11:11:53 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44894 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726373AbfHSPLx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Aug 2019 11:11:53 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 803141FAA64;
        Mon, 19 Aug 2019 15:11:53 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-125-188.rdu2.redhat.com [10.10.125.188])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 486A0871F6;
        Mon, 19 Aug 2019 15:11:53 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id 43DA0180542; Mon, 19 Aug 2019 11:11:52 -0400 (EDT)
Date:   Mon, 19 Aug 2019 11:11:52 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/16] Cache open file descriptors in knfsd
Message-ID: <20190819151152.GU5398@parsley.fieldses.org>
References: <20190818181859.8458-1-trond.myklebust@hammerspace.com>
 <20190819150158.GB18075@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819150158.GB18075@fieldses.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.71]); Mon, 19 Aug 2019 15:11:53 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Aug 19, 2019 at 11:01:58AM -0400, J. Bruce Fields wrote:
> On Sun, Aug 18, 2019 at 02:18:43PM -0400, Trond Myklebust wrote:
> > v2:
> > - Fix a double semicolon in fs/nfsd/filecache.c
> > - Adjust changelog for "nfsd: rip out the raparms cache" as per Chuck's
> >   request.
> 
> Thanks, replaced the series in my -next branch with this version.

Whoops, forgot about some fixes required for the /proc/fs/nfsd/clients
stuff.  We'll see if the various robots notice that my -next tree
briefly didn't compile.

--b.
