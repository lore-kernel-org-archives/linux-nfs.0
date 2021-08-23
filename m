Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D1E9C4338F
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Aug 2021 14:48:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4A4C9610C9
	for <linux-nfs@archiver.kernel.org>; Mon, 23 Aug 2021 14:48:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230034AbhHWOsp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 23 Aug 2021 10:48:45 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34634 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230032AbhHWOsp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2021 10:48:45 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3FDF3C061575
        for <linux-nfs@vger.kernel.org>; Mon, 23 Aug 2021 07:48:03 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 6CEE3581C; Mon, 23 Aug 2021 10:48:02 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 6CEE3581C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1629730082;
        bh=v0/Y87o8L6bvjqHmgHYNS3RpmWW4Z6NbehfXQm/fKDE=;
        h=Date:To:Subject:From:From;
        b=YFBH3EMR8Oz7YaUQpIts7BvAMKggQv6sAZzRxcuC744W4ZO5GP9lRP3F3VMoYBltT
         gGRwwjB5WloSvZoazR97Cuzj0KMLbS+q3GJQMZnvMDubdW7iK76xY2hPLejxKuckB0
         4kxVMSAeMnlkhHNLEYdo0Fz6ltULbsoUm0yw6nco=
Date:   Mon, 23 Aug 2021 10:48:02 -0400
To:     linux-nfs@vger.kernel.org
Subject: sporadic generic/154 failure
Message-ID: <20210823144802.GA883@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'm seeing generic/154 failing sometimes.

It does a "cp --reflink" (which uses FI_CLONE, which results in a
->remap_file_range call that NFS maps to the CLONE operation), then
overwriting parts of the fire, and checking free blocks (with "stat -f
/path -c "%f") at various points, and failing when the number of free
blocks is outside an expected range.

I don't know if it might be some caching issue, or something about how
NFS reports free blocks.

Honestly it looks unlikely to be critical, so for now I'm ignoring
it....

--b.
