Return-Path: <SRS0=Zlln=DN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47849C41604
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Oct 2020 15:13:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A5764206DD
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Oct 2020 15:13:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="sUWsdXHa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725943AbgJFPNi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Oct 2020 11:13:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42392 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725902AbgJFPNh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2020 11:13:37 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 70330C061755
        for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2020 08:13:37 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id D1A596EEE; Tue,  6 Oct 2020 11:13:35 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org D1A596EEE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1601997215;
        bh=8BPexV5KqD7xKJ7XgsEB4+OnSEoH97uVeJy4DskuRgo=;
        h=Date:To:Subject:From:From;
        b=sUWsdXHadEPLwPA0MLnFX0lr3vNkJsN8kp6DW5D3qZkg38EwYz8yZdl3/nzNxLxFB
         MRtp4lJGwQ4XfE10Yzy3u00huvsB2oLnbbAllYOvcfxKcVEZ1mChkcc2HoCAGD0TIc
         l2XlgfY8vMYzrhpyTXxEqpLhfhJxeaZl/SEzMEwU=
Date:   Tue, 6 Oct 2020 11:13:35 -0400
To:     linux-nfs@vger.kernel.org
Subject: unsharing tcp connections from different NFS mounts
Message-ID: <20201006151335.GB28306@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFSv4.1+ differs from earlier versions in that it always performs
trunking discovery that results in mounts to the same server sharing a
TCP connection.

It turns out this results in performance regressions for some users;
apparently the workload on one mount interferes with performance of
another mount, and they were previously able to work around the problem
by using different server IP addresses for the different mounts.

Am I overlooking some hack that would reenable the previous behavior?
Or would people be averse to an "-o noshareconn" option?

--b.
