Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48656 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751653AbeFXU0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 24 Jun 2018 16:26:16 -0400
Date: Sun, 24 Jun 2018 16:26:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Manjunath Patil <manjunath.b.patil@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
Message-ID: <20180624202615.GA31496@fieldses.org>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180622175416.GA7119@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, could you share some more details with us about the
situation when you (or your customers) are actually hitting this case?

How many clients, what kind of clients, etc.  And what version of the
server were you seeing the problem on?  (I'm mainly curious whether
de766e570413 and 44d8660d3bb0 were already applied.)

I'm glad we're thinking about how to handle this case, but my feeling is
that the server is probably just being *much* too conservative about
these allocations, and the most important thing may be to fix that and
make it a lot rarer that we hit this case in the first place.

--b.
