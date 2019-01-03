Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 947BFC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 17:41:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5FAC3208E3
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 17:41:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730270AbfACRlK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 12:41:10 -0500
Received: from mail-pl1-f194.google.com ([209.85.214.194]:33543 "EHLO
        mail-pl1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728782AbfACRlK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 12:41:10 -0500
Received: by mail-pl1-f194.google.com with SMTP id z23so16200605plo.0;
        Thu, 03 Jan 2019 09:41:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ieuarke/oV/UnSBEv3TcuZvMHIFmRjHzDOpH+7Z5E2w=;
        b=ZqRvtxabRB5DYv4H3EIH7YWmVqjrV7+0Avemsdrq3uvDEwu4q2aAaFr80VH2ISqUUf
         JYIBHWRHUTQ/9s9TQceScu+cJQJS6Iiti/TxIE98x1EWmD35u2Py4wxIDAOzmjtfE+/6
         qJVOXQleHYxTEkfxeN9bC1oZW2X0QEHmakE1pNodl1N9qYue/DeRhr+leXyK5CyiFQS0
         QcMIVmwKFVd3Gb0r7UbSSbHlAOmNjkF5QzoYeIYOGr+3c98ykUGvCODgBASEJ1pbDqsk
         0rg0JFwMFmeLJk4aIIA53sEjiWnyDUWY7vty5wTS7XrM9FXecbSKGapjXMtAqY9DwRZs
         fZ1A==
X-Gm-Message-State: AJcUukf3zds7O4aUNJfL9rvh/fLnBNDwar4WMHNCM+5gO4Pn2npEQwl2
        bgPSRtzZFLYAgu0sqPq+i38=
X-Google-Smtp-Source: ALg8bN78OVqeOXr3hDuiUGzoiOI3g8QG6pzvdfONpyGLhiOWQpiXcM6/CyFSB7rUxwqjN53rdfnBRQ==
X-Received: by 2002:a17:902:20c8:: with SMTP id v8mr48508956plg.319.1546537269057;
        Thu, 03 Jan 2019 09:41:09 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id i1sm84743848pgb.46.2019.01.03.09.41.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 09:41:08 -0800 (PST)
Message-ID: <1546537266.163063.16.camel@acm.org>
Subject: Re: [PATCH net-next] svcrdma: Fix an uninitialized variable false
 warning
From:   Bart Van Assche <bvanassche@acm.org>
To:     Chuck Lever <chuck.lever@oracle.com>,
        YueHaibing <yuehaibing@huawei.com>
Cc:     "David S. Miller" <davem@davemloft.net>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        open list <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jason Gunthorpe <jgg@ziepe.ca>
Date:   Thu, 03 Jan 2019 09:41:06 -0800
In-Reply-To: <282B8BD1-FE2A-4FE4-9520-144ACF5CB74C@oracle.com>
References: <20181220094921.3396-1-yuehaibing@huawei.com>
         <282B8BD1-FE2A-4FE4-9520-144ACF5CB74C@oracle.com>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-12-28 at 10:36 -0500, Chuck Lever wrote:
+AD4 +AD4 On Dec 20, 2018, at 4:49 AM, YueHaibing +ADw-yuehaibing+AEA-huawei.com+AD4 wrote:
+AD4 +AD4 
+AD4 +AD4 smatch warning this:
+AD4 +AD4 net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c:351 svc+AF8-rdma+AF8-post+AF8-chunk+AF8-ctxt() error: uninitialized symbol 'bad+AF8-wr'
+AD4 +AD4 net/sunrpc/xprtrdma/verbs.c:1569 rpcrdma+AF8-post+AF8-recvs() error: uninitialized symbol 'bad+AF8-wr'
+AD4 +AD4 
+AD4 +AD4 'bad+AF8-wr' is initialized in ib+AF8-post+AF8-send. But smatch
+AD4 +AD4 doesn't know that and warns this.
+AD4 +AD4 
+AD4 +AD4 Signed-off-by: YueHaibing +ADw-yuehaibing+AEA-huawei.com+AD4
+AD4 +AD4 ---
+AD4 +AD4 net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c +AHw 2 +--
+AD4 +AD4 net/sunrpc/xprtrdma/verbs.c       +AHw 2 +--
+AD4 +AD4 2 files changed, 2 insertions(+-), 2 deletions(-)
+AD4 +AD4 
+AD4 +AD4 diff --git a/net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c b/net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c
+AD4 +AD4 index dc19517..0954b25 100644
+AD4 +AD4 --- a/net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c
+AD4 +AD4 +-+-+- b/net/sunrpc/xprtrdma/svc+AF8-rdma+AF8-rw.c
+AD4 +AD4 +AEAAQA -308,7 +-308,7 +AEAAQA static int svc+AF8-rdma+AF8-post+AF8-chunk+AF8-ctxt(struct svc+AF8-rdma+AF8-chunk+AF8-ctxt +ACo-cc)
+AD4 +AD4 	struct svcxprt+AF8-rdma +ACo-rdma +AD0 cc-+AD4-cc+AF8-rdma+ADs
+AD4 +AD4 	struct svc+AF8-xprt +ACo-xprt +AD0 +ACY-rdma-+AD4-sc+AF8-xprt+ADs
+AD4 +AD4 	struct ib+AF8-send+AF8-wr +ACo-first+AF8-wr+ADs
+AD4 +AD4 -	const struct ib+AF8-send+AF8-wr +ACo-bad+AF8-wr+ADs
+AD4 +AD4 +-	const struct ib+AF8-send+AF8-wr +ACo-bad+AF8-wr +AD0 NULL+ADs
+AD4 +AD4 	struct list+AF8-head +ACo-tmp+ADs
+AD4 +AD4 	struct ib+AF8-cqe +ACo-cqe+ADs
+AD4 +AD4 	int ret+ADs
+AD4 +AD4 diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
+AD4 +AD4 index 3ddba94..37be70f 100644
+AD4 +AD4 --- a/net/sunrpc/xprtrdma/verbs.c
+AD4 +AD4 +-+-+- b/net/sunrpc/xprtrdma/verbs.c
+AD4 +AD4 +AEAAQA -1518,7 +-1518,7 +AEAAQA void
+AD4 +AD4 rpcrdma+AF8-post+AF8-recvs(struct rpcrdma+AF8-xprt +ACo-r+AF8-xprt, bool temp)
+AD4 +AD4 +AHs
+AD4 +AD4 	struct rpcrdma+AF8-buffer +ACo-buf +AD0 +ACY-r+AF8-xprt-+AD4-rx+AF8-buf+ADs
+AD4 +AD4 -	struct ib+AF8-recv+AF8-wr +ACo-wr, +ACo-bad+AF8-wr+ADs
+AD4 +AD4 +-	struct ib+AF8-recv+AF8-wr +ACo-wr, +ACo-bad+AF8-wr +AD0 NULL+ADs
+AD4 +AD4 	int needed, count, rc+ADs
+AD4 +AD4 
+AD4 +AD4 	rc +AD0 0+ADs
+AD4 +AD4 -- 
+AD4 +AD4 2.7.0
+AD4 
+AD4 Does this need
+AD4 
+AD4 Fixes: d34ac5cd3a73 (+ACI-RDMA, core and ULPs: Declare ib+AF8-post+AF8-send() and ib+AF8-post+AF8-recv() arguments const+ACI)  ???
+AD4 
+AD4 Bart, any comments?

Hi Chuck,

My understanding is that the +ACI-Fixes:+ACI tag should only be used for patches
that fix bugs. Since this patch addresses a false positive warning reported
by smatch I think that it would be misleading to use the +ACI-Fixes:+ACI tag.
Before proceeding with this patch, I think that smatch should be improved.
The following patch namely was not sufficient to suppress the xprtrdma
warning reported by smatch:

diff --git a/include/rdma/ib+AF8-verbs.h b/include/rdma/ib+AF8-verbs.h
index a3ceed3a040a..498eaa245d1a 100644
--- a/include/rdma/ib+AF8-verbs.h
+-+-+- b/include/rdma/ib+AF8-verbs.h
+AEAAQA -3327,9 +-3327,16 +AEAAQA static inline int ib+AF8-post+AF8-srq+AF8-recv(struct ib+AF8-srq +ACo-srq,
 				   const struct ib+AF8-recv+AF8-wr +ACoAKg-bad+AF8-recv+AF8-wr)
 +AHs
 	const struct ib+AF8-recv+AF8-wr +ACo-dummy+ADs
-
-	return srq-+AD4-device-+AD4-ops.post+AF8-srq+AF8-recv(srq, recv+AF8-wr,
-					      bad+AF8-recv+AF8-wr ? : +ACY-dummy)+ADs
+-	int ret+ADs
+-
+-	ret +AD0 srq-+AD4-device-+AD4-ops.post+AF8-srq+AF8-recv(srq, recv+AF8-wr,
+-					     bad+AF8-recv+AF8-wr ? : +ACY-dummy)+ADs
+-+ACM-ifdef +AF8AXw-CHECKER+AF8AXw
+-	/+ACo Tell static analyzers that +ACo-bad+AF8-send+AF8-wr is initialized if ret +ACEAPQ 0 +ACo-/
+-	if (ret +ACYAJg bad+AF8-send+AF8-wr)
+-		+ACo-bad+AF8-send+AF8-wr +AD0 +ACo-bad+AF8-send+AF8-wr+ADs
+-+ACM-endif
+-	return ret+ADs
 +AH0
 
 /+ACoAKg
+AEAAQA -3431,8 +-3438,15 +AEAAQA static inline int ib+AF8-post+AF8-send(struct ib+AF8-qp +ACo-qp,
 			       const struct ib+AF8-send+AF8-wr +ACoAKg-bad+AF8-send+AF8-wr)
 +AHs
 	const struct ib+AF8-send+AF8-wr +ACo-dummy+ADs
+-	int ret+ADs
 
-	return qp-+AD4-device-+AD4-ops.post+AF8-send(qp, send+AF8-wr, bad+AF8-send+AF8-wr ? : +ACY-dummy)+ADs
+-	ret +AD0 qp-+AD4-device-+AD4-ops.post+AF8-send(qp, send+AF8-wr, bad+AF8-send+AF8-wr ? : +ACY-dummy)+ADs
+-+ACM-ifdef +AF8AXw-CHECKER+AF8AXw
+-	/+ACo Tell static analyzers that +ACo-bad+AF8-send+AF8-wr is initialized if ret +ACEAPQ 0 +ACo-/
+-	if (ret +ACYAJg bad+AF8-send+AF8-wr)
+-		+ACo-bad+AF8-send+AF8-wr +AD0 +ACo-bad+AF8-send+AF8-wr+ADs
+-+ACM-endif
+-	return ret+ADs
 +AH0
 
 /+ACoAKg
+AEAAQA -3448,8 +-3462,15 +AEAAQA static inline int ib+AF8-post+AF8-recv(struct ib+AF8-qp +ACo-qp,
 			       const struct ib+AF8-recv+AF8-wr +ACoAKg-bad+AF8-recv+AF8-wr)
 +AHs
 	const struct ib+AF8-recv+AF8-wr +ACo-dummy+ADs
+-	int ret+ADs
 
-	return qp-+AD4-device-+AD4-ops.post+AF8-recv(qp, recv+AF8-wr, bad+AF8-recv+AF8-wr ? : +ACY-dummy)+ADs
+-	ret +AD0 qp-+AD4-device-+AD4-ops.post+AF8-recv(qp, recv+AF8-wr, bad+AF8-recv+AF8-wr ? : +ACY-dummy)+ADs
+-+ACM-ifdef +AF8AXw-CHECKER+AF8AXw
+-	/+ACo Tell static analyzers that +ACo-bad+AF8-send+AF8-wr is initialized if ret +ACEAPQ 0 +ACo-/
+-	if (ret +ACYAJg bad+AF8-send+AF8-wr)
+-		+ACo-bad+AF8-send+AF8-wr +AD0 +ACo-bad+AF8-send+AF8-wr+ADs
+-+ACM-endif
+-	return ret+ADs
 +AH0
 
 struct ib+AF8-cq +ACoAXwBf-ib+AF8-alloc+AF8-cq(struct ib+AF8-device +ACo-dev, void +ACo-private,

Bart.
