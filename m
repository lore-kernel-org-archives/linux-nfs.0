Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA024C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:18:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A61BF218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:18:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=netronome-com.20150623.gappssmtp.com header.i=@netronome-com.20150623.gappssmtp.com header.b="USLz8pGk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726684AbfCOTST (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 15:18:19 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:46722 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726431AbfCOTST (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 15:18:19 -0400
Received: by mail-qk1-f193.google.com with SMTP id i5so6163279qkd.13
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 12:18:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netronome-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :organization:mime-version:content-transfer-encoding;
        bh=Mi2MIG1/mzPXV8jB4kkXczXP4yGUqOQvOUCOqbJhIPc=;
        b=USLz8pGkUTdDRHGREx/MScK995EmojYF20KnWY4kAltTpMcjUz1n/KmB5u6vfBEjoQ
         i9GXxLDzCSi15g3kJ/Nd9iUC/gZ4SS6DbxUioCvn1C+Iht9v6omYJ0uZiwXJkQve94lu
         FEXJxQoOVuVygX1IzKpKSVu0mQ8Z/yk5n/01jho9F21jmvYnRuhpG9OPf3+heaTk9keb
         tH/tqMNt2eysFbgxdNxH87L6ep9QCSlfyaQbl6y9dPWAixKhMzhVwWt82n93oEsfkstB
         Jz9YDT22cLCxYzc4lJmU3nl6/6mAvJba1khQnAqU0CtJbl4phvj7DtMVQdcsw7eXb6bR
         Jq5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:in-reply-to
         :references:organization:mime-version:content-transfer-encoding;
        bh=Mi2MIG1/mzPXV8jB4kkXczXP4yGUqOQvOUCOqbJhIPc=;
        b=NYAactMtysu9yqFFNExbDsnVsScNFPtO6NA/X7YmxRV6+pDoAmxVUpWc9xIk3kjat6
         Qgu3Sqn23WUqTmfWV5XUIw3A+6FRaERFCdoUCgbksmP7A100tAIHjw0I9PiD7oR58Rfi
         AcXAkC4nRIQvHF61NIi5ejQyznCRZApIijM7BCmOIZwNrpg6pVaPf4ReZ/E8Xfee397j
         /xn/rQLJpxOmxnSF7vU3g3MkNPlulyaakQkD3Zf7sUbe5OLEAp8c2zZM6pCAB5adiKzn
         e1xEzhY74d3wdnlwHBvUejZhoeN0IVKfmSNZQozlRb06FGn5O0q1XkieuYCKXlx4K+wp
         d+Yg==
X-Gm-Message-State: APjAAAVOln8kZwPmIlfYm51efZfvP1QNIh3vDLbfqtmbsDeEdKJv+vAW
        9EtT4xDQvNZy3Qiq2LYScqS+u6lVruo=
X-Google-Smtp-Source: APXvYqz5LusrdYt5oA+YWXCkjYY1VU/59i9ijFSZEVBiIBkENmeo9KJ3YQV63+iMaCqLurg2HnqB+Q==
X-Received: by 2002:a05:620a:146a:: with SMTP id j10mr3881298qkl.243.1552677498064;
        Fri, 15 Mar 2019 12:18:18 -0700 (PDT)
Received: from cakuba.netronome.com ([66.60.152.14])
        by smtp.gmail.com with ESMTPSA id 50sm1503716qtr.96.2019.03.15.12.18.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 12:18:17 -0700 (PDT)
Date:   Fri, 15 Mar 2019 12:18:13 -0700
From:   Jakub Kicinski <jakub.kicinski@netronome.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
Message-ID: <20190315121813.288f406e@cakuba.netronome.com>
In-Reply-To: <20190315120815.543f4cd0@cakuba.netronome.com>
References: <20190315110555.0807d015@cakuba.netronome.com>
        <f74ac3d790748542914ca545a88d34e7cb644f33.camel@hammerspace.com>
        <20190315120815.543f4cd0@cakuba.netronome.com>
Organization: Netronome Systems, Ltd.
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Mar 2019 12:08:15 -0700, Jakub Kicinski wrote:
> On Fri, 15 Mar 2019 18:41:20 +0000, Trond Myklebust wrote:
> > On Fri, 2019-03-15 at 11:05 -0700, Jakub Kicinski wrote:  
> > > Hi,
> > > 
> > > I just upgraded from:
> > > 
> > > commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
> > > Merge: c6873d18cb4a 24319258660a
> > > Author: David S. Miller <davem@davemloft.net>
> > > Date:   Mon Mar 11 16:22:49 2019 -0700
> > > 
> > > to
> > > 
> > > commit 3b319ee220a8795406852a897299dbdfc1b09911
> > > Merge: 9352ca585b2a b6e88119f1ed
> > > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > > Date:   Thu Mar 14 10:48:14 2019 -0700
> > > 
> > > and I'm seeing:
> > > 
> > > # mount /home/
> > > mount.nfs: Protocol error
> > > 
> > > No errors in dmesg, please let me know if it's a known problem or
> > > what
> > > other info could be of use.    
> > 
> > It sounds like the exact same problem that Marc Dionne reported seeing.
> > Can you also try the patch at 
> > http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=patch;h=513149607d19bc3821386fb5ac75f8b99fd4b115
> > ?  
> 
> Sorry, I didn't see your reply, trying now..

Didn't seem to help:

$ git show
commit a79da625d196d00d19e8cbf8ec6eff3a323e3423 (HEAD -> work)
Author: Trond Myklebust <trond.myklebust@hammerspace.com>
Date:   Fri Mar 15 12:55:59 2019 -0400

    SUNRPC: Fix the minimal size for reply buffer allocation
    
    We must at minimum allocate enough memory to be able to see any auth
    errors in the reply from the server.
    
    Fixes: 2c94b8eca1a26 ("SUNRPC: Use au_rslack when computing reply...")
    Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4216fe33204a..310873895578 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1730,7 +1730,12 @@ call_allocate(struct rpc_task *task)
        req->rq_callsize = RPC_CALLHDRSIZE + (auth->au_cslack << 1) +
                           proc->p_arglen;
        req->rq_callsize <<= 2;
-       req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + proc->p_replen;
+       /*
+        * Note: the reply buffer must at minimum allocate enough space
+        * for the 'struct accepted_reply' from RFC5531.
+        */
+       req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + \
+                       max_t(size_t, proc->p_replen, 2);
        req->rq_rcvsize <<= 2;
 
        status = xprt->ops->buf_alloc(task);

# uname -r
5.0.0-11527-ga79da625d196
# mount /home/
mount.nfs: Protocol error
