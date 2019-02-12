Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 707B9C282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 18:27:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3838C222C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 18:27:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549996058;
	bh=PNpbkcRbbXPVhdxQGFCpfM+tGy2YMqDGStMNrusOHtU=;
	h=Date:From:To:Cc:Subject:List-ID:From;
	b=ofxUsFxvz/DPTY8T5EPqlaFuutxwoeMx7Mqpx49YINmcN9gu8HqLroDk5jVGwKShp
	 30Ld3tyJT1ybjl0ZiItb95nVL/1VwYHQCj9YrWN0oLe1ozB2k1ESVX40zDEMr7plGv
	 fgLBb+JV5dLcE6IxvrmIv+pVLMnkkKL2CEpBNI5w=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730205AbfBLS1h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 13:27:37 -0500
Received: from mail.kernel.org ([198.145.29.99]:60134 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729198AbfBLS1h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 13:27:37 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 18351222BB;
        Tue, 12 Feb 2019 18:27:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549996056;
        bh=PNpbkcRbbXPVhdxQGFCpfM+tGy2YMqDGStMNrusOHtU=;
        h=Date:From:To:Cc:Subject:From;
        b=O3RgSNCL1YIE8l4ZaxLG3upkKFikPc2FRbnND2SjcWwuBfQVzqJb9qg++v0wshRYO
         JQhNAx53W9sOmlBuDsPMf+2FmHT38Ejl1umkxHUZP7fTb2UmokCEXj1CRhHqvmumoO
         PNHqb+TiOjM7uMN2IRufB+z0s26QrOjsMohhg7j4=
Date:   Tue, 12 Feb 2019 19:27:34 +0100
From:   Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Subject: [PATCH] rpc: properly check debugfs dentry before using it
Message-ID: <20190212182734.GA4509@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

debugfs can now report an error code if something went wrong instead of
just NULL.  So if the return value is to be used as a "real" dentry, it
needs to be checked if it is an error before dereferencing it.

This is now happening because of ff9fb72bc077 ("debugfs: return error
values, not NULL"), but why debugfs files are not being created properly
is an older issue, probably one that has always been there and should
probably be looked at...

Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Reported-by: David Howells <dhowells@redhat.com>
Tested-by: David Howells <dhowells@redhat.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/sunrpc/debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I can take this through my tree if people don't object, or it can go
through the NFS tree.  It does need to get merged before 5.0-final
though.

I also have a "larger" debugfs cleanup patch for this file, but that's
not really 5.0-final material and I will send it out later.

thanks,

greg k-h

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 45a033329cd4..19bb356230ed 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -146,7 +146,7 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	rcu_read_lock();
 	xprt = rcu_dereference(clnt->cl_xprt);
 	/* no "debugfs" dentry? Don't bother with the symlink. */
-	if (!xprt->debugfs) {
+	if (IS_ERR_OR_NULL(xprt->debugfs)) {
 		rcu_read_unlock();
 		return;
 	}
