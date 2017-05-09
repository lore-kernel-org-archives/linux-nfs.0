Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:33331 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbdEIJUQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:16 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: RFC: remove function pointer casts and constify function tables
Date: Tue,  9 May 2017 11:19:38 +0200
Message-Id: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series was inspired by two recent events:  talking to a academic
researcher about the harm of function pointer casts for static analysis
at a conference, and reading up the whole Grsecurity drama, including
finding that their patchset does a lot of work to remove these casts
in sunrpc and nfs (and in fact those seem the biggest culprit in the
kernel), and constifying the operation vectors like so many others in
the kernel, although done in a rather hacky and/or mechnical way.

This series tries to solve both patches properly, and except for two
hacks that simply remove the p_count and pc_count counters should
be reasonably clean.  I'd love to hear feedback especially for those
two patches, and if maybe no one actually cares about those counters
in the end, which would make my life easier by not having to find
a replacement mechnism.

Note that the first part of the series is about the RPC forechannel,
and the latter about the backchannel, but due to bidirection operation
in NFSv4 there is no really clean split between the client and server
parts.
