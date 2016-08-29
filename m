Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.math.uh.edu ([129.7.128.33]:54380 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbcH2RaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Aug 2016 13:30:19 -0400
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Oleg Drokin <green@linuxhacker.ru>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix infinite looping in rpc_clnt_iterate_for_each_xprt
References: <1468685090-5513-1-git-send-email-trond.myklebust@primarydata.com>
Date: Mon, 29 Aug 2016 11:49:51 -0500
In-Reply-To: <1468685090-5513-1-git-send-email-trond.myklebust@primarydata.com>
        (Trond Myklebust's message of "Sat, 16 Jul 2016 12:04:50 -0400")
Message-ID: <ufah9a3wmds.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have found (with Chuck's help) that this patch appears to fix an issue
I've been struggling with for the past couple of weeks, where my clients
will just hammer the server with BIND_CONN_TO_SESSION requests endlessly
until the server dies from OOM.  Really, Chuck found the patch and all I
did was apply it locally.  At least that issue hasn't reoccurred so far.

The server probably shouldn't die from a confused client, but that's a
separate issue.

However, this patch isn't tagged for stable.  Would you consider
submitting it there?  I'm hoping that Fedora will integrate it locally
but I think it would be of more general use.

Thanks,
-- 
 Jason L Tibbitts III - tibbs@math.uh.edu - 713/743-3486 - 660PGH
 System Manager:  University of Houston Department of Mathematics 
