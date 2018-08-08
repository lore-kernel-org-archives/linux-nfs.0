Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:33754 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727530AbeHHXQb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2018 19:16:31 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: RFC: xprt_lock_connect
Message-Id: <55352755-3A99-4193-98E6-25A9B8181F6E@oracle.com>
Date: Wed, 8 Aug 2018 15:53:34 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

For maintainability and legibility, I'm attempting to make the
the RPC/RDMA connect logic act a little more like the TCP
connect logic. I noticed this patch:

commit 718ba5b87343df303017585200ee182e937eabfc
Author:     Trond Myklebust <trond.myklebust@primarydata.com>
AuthorDate: Sun Feb 8 18:19:25 2015 -0500
Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
CommitDate: Sun Feb 8 21:47:29 2015 -0500

    SUNRPC: Add helpers to prevent socket create from racing

    The socket lock is currently held by the task that is requesting the
    connection be established. While that is efficient in the case where
    the connection happens quickly, it is racy in the case where it doesn't.
    What we really want is for the connect helper to be able to block access
    to the socket while it is being set up.
    
    This patch does so by arranging to transfer the socket lock from the
    task that is requesting the connect attempt, and then releasing that
    lock once everything is done.
    This scheme also gives us automatic protection against collisions with
    the RPC close code, so we can kill the cancel_delayed_work_sync()
    call in xs_close().
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Your patch description refers to "the socket lock" but it appears
to be manipulating the transport send lock. The new helpers are
added in net/sunrpc/xprt.c, not in xprtsock.c. And, there is a
hunk that changes the generic xprt_connect() function.

Therefore, I'm wondering if these helpers are of value also to
other transports that make use of connections. Should xprtrdma
adopt the use of these helpers too?


--
Chuck Lever



