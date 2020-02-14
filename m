Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDDE5C35242
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 20:45:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD88F22314
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 20:45:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730260AbgBNUpp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 15:45:45 -0500
Received: from fieldses.org ([173.255.197.46]:34848 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727742AbgBNUpo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 15:45:44 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 1146988A; Fri, 14 Feb 2020 15:45:44 -0500 (EST)
Date:   Fri, 14 Feb 2020 15:45:44 -0500
To:     linux-nfs@vger.kernel.org
Subject: pynfs python 3 flag day
Message-ID: <20200214204544.GA30533@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'm hearing more noise about deprecating Python 2, so decided I can't
keep ignoring Python 3.

Getting pynfs working on Python 3 is a bigger project than I expected.
Keeping it working under Python 2 looks like another project.  So, I'm
planning a flag day after which pynfs will require Python 3.

That isn't the way I'd prefer to do it, but there's only so much time I
want to spend on this.

I've mostly got the 4.0 server tests working under python 3.  I hope a
few more days will be enough to get the 4.1 tests working as well.

When I switch over, I'm afraid a few things will be left broken: any
tests that I don't personally run may still have minor python 3 bugs,
and I haven't touched the python server code that's used for client
testing.

If you stumble across something broken, and you can give me a simple
reproducer, feel free to share it with me and I'll take a look.

But for anything complicated, I'll probably need patches.

Again, I apologize for any extra work that creates for anyone, but for
now this seems like the best compromise to keep things mostly working
without it becoming a bigger time sink for me.

Work so far is in the "python3" branch at

	git://linux-nfs.org/~bfields/pynfs.git

The history will probably be cleaned up an rewritten before it's done.
I'm hoping that'll be in the next week.

It's mostly just a matter of separating out unicode strings and byte
arrays.  Protocol data is all the latter (even if the protocol prefers
some field to be UTF8, pynfs still needs to be able to handle non-UTF8).
But some things have to be unicode strings.

--b.
