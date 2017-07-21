Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34486 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752091AbdGUVpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 17:45:47 -0400
Date: Fri, 21 Jul 2017 17:45:47 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: delegation self-conflicts
Message-ID: <20170721214547.GD21235@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I finally got around to looking at the delegation self-conflict problem
you asked me about: it looks not hard at all to make the server stop
revoking delegation in cases it's the client modifiying the file (or
metatadata), as long as we're in the 4.1 case or otherwise know which
client we're dealing with.  I should post patches next week.

Remind me how you expect to take advantage of this?  I think you wanted
to eliminate some cases where the client has to preemptively return
delegations, but don't you then need some way to know ahead of time what
the server behavior is?

--b.
