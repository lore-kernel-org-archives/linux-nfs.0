Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCE8FC433ED
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 03:34:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 85E3561153
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 03:34:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229658AbhEDDfl convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 May 2021 23:35:41 -0400
Received: from mx2.suse.de ([195.135.220.15]:39740 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229499AbhEDDfl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 May 2021 23:35:41 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
X-Amavis-Alert: BAD HEADER SECTION, Duplicate header field: "Cc"
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 27D28B14E;
        Tue,  4 May 2021 03:34:46 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Yongcheng Yang" <yoyang@redhat.com>
Cc:     "Steve Dickson" <steved@redhat.com>
Cc:     "Linux NFS Mailing list" <linux-nfs@vger.kernel.org>,
        "Yongcheng Yang" <yoyang@redhat.com>,
        "Petr Pisar" <ppisar@redhat.com>
Subject: Re: [PATCH] systemd: nfs-server.service add "Wants" dependency on
 rpc-rquotad.service
In-reply-to: <20210430065601.16523-1-yoyang@redhat.com>
References: <20210430065601.16523-1-yoyang@redhat.com>
Date:   Tue, 04 May 2021 13:34:41 +1000
Message-id: <162009928153.6582.2032158868104502300@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 30 Apr 2021, Yongcheng Yang wrote:
> The RPC quota service was part of nfs-utils and started together
> with nfs-server before it was splitting out from nfs-utils.
> 
> It would be convenient to preserve the behavior: Let nfs-server
> start rpc-rquotad automatically.
> 
> Signed-off-by: Petr Pisar <ppisar@redhat.com>
> Signed-off-by: Yongcheng Yang <yoyang@redhat.com>

I would prefer that whatever package provides rpc-rquotad should take
care of this.
It can provide a "wants" symlink

  .../systemd/system/nfs-server.wants/rpc-rquotad.service -> .../rpc-rquotad.service

NeilBrown
