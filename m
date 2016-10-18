Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39764 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755290AbcJRVh4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Oct 2016 17:37:56 -0400
Date: Tue, 18 Oct 2016 17:37:55 -0400
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-nfs@vger.kernel.org
Subject: sg_set_buf
Message-ID: <20161018213755.GA10777@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS code is using sg_set_buf to turn a bit of stack menory into a
scatterlist it can pass to the crypto code.  That started BUG()ing as of
ac4e97abce9b "scatterlist: sg_set_buf() argument must be in linear
mapping".

Is that BUG() being overly strict, or is this something we should never
have been doing in the first place?

--b.
