Return-Path: <SRS0=/T82=7V=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20130C433E0
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jun 2020 21:19:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 02D362074B
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jun 2020 21:19:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726606AbgFHVTp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Jun 2020 17:19:45 -0400
Received: from fieldses.org ([173.255.197.46]:34790 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726566AbgFHVTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jun 2020 17:19:45 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 08FDB878C; Mon,  8 Jun 2020 17:19:45 -0400 (EDT)
Date:   Mon, 8 Jun 2020 17:19:45 -0400
To:     linux-nfs@vger.kernel.org
Subject: client caching and locks
Message-ID: <20200608211945.GB30639@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

What does the client do to its cache when it writes to a locked range?

The RFC:

	https://tools.ietf.org/html/rfc7530#section-10.3.2

seems to apply that you should get something like local-filesystem
semantics if you write-lock any range that you write to and read-lock
any range that you read from.

But I see a report that when applications write to non-overlapping
ranges (while taking locks over those ranges), they don't see each
other's updates.

I think for simultaneous non-overlapping writes to work that way, the
client would need to invalidate its cache on unlock (except for the
locked range).  But i can't tell what the client's designed to do.

--b.
