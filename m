Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A126C433C1
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 14:14:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 06D39619BD
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 14:14:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231627AbhC3OOW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Mar 2021 10:14:22 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42156 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231710AbhC3OOB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Mar 2021 10:14:01 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D9971C061574
        for <linux-nfs@vger.kernel.org>; Tue, 30 Mar 2021 07:14:00 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 21E24200B; Tue, 30 Mar 2021 10:13:59 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 21E24200B
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1617113639;
        bh=Y9LfZVLxuKGA0TLLTcdK+WKmvUscuQZOjuz6NtZ5wWQ=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=mrBKh2o2BW67HbVRYZX9lGF/sI2MANyUDmwBV17JrU2ZxaKsRAyErPUbUQ/7ZJPhr
         rybVNij9H0OkZX0axVtMG/3sI1t40soX7hAv6AR2Qw0GNC0eCqVnzvNLlY071wcaH1
         71MJjTRfLrxd48vWWOyRz4Agj3BVzvztdQSEPStQ=
Date:   Tue, 30 Mar 2021 10:13:59 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Benjamin Maynard <benmaynard@google.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: Input/output errors when mounting re-exported directories that
 use crossmounts
Message-ID: <20210330141359.GA8841@fieldses.org>
References: <CA+QRt4vr+CUgP-4xkVQwLWNZMHo-w6TwU8bFwzuZcUc1RPi-RA@mail.gmail.com>
 <20210325213421.GC18351@fieldses.org>
 <CA+QRt4srUGGgqYPs6bufihOrC8wUZ0-B5yzXjN7rrh=EdTatAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+QRt4srUGGgqYPs6bufihOrC8wUZ0-B5yzXjN7rrh=EdTatAA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

One of my pie-in-the-sky ideas here is to allow running the server in a
mode where it re-exports one server and has no other exports whatsoever.

That would mean that when the re-exporting server gets a filehandle, it
knows it originated from that one server, and if necessary it can do
things like issue a getattr on that filehandle for the fsid to find out
which filesystem it belongs to.

It's a major restriction, but I figure that might be what you're doing
anyway in a case like yours.  Perhaps containers or VMs would be a
workaround if you want to server more exports from the same physical
hardware.

But, anyway, I'm not actually sure how to make that work and it's not
currently on the todo list.

--b.
