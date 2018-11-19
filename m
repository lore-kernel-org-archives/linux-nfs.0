Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A28EC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:59:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBF5D20831
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:59:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBF5D20831
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730219AbeKTGYt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 01:24:49 -0500
Received: from fieldses.org ([173.255.197.46]:57166 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725963AbeKTGYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 01:24:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id B492A2016; Mon, 19 Nov 2018 14:59:37 -0500 (EST)
Date:   Mon, 19 Nov 2018 14:59:37 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill
 helper
Message-ID: <20181119195937.GB22976@fieldses.org>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151905.21878.62693.stgit@klimt.1015granger.net>
 <20181115163246.GB9022@fieldses.org>
 <A6FEE9E7-0226-460F-AA3E-42D7CEE9A781@oracle.com>
 <20181119195442.GA22976@fieldses.org>
 <A6299E15-DDDB-4BF4-8F54-62BC799215AF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A6299E15-DDDB-4BF4-8F54-62BC799215AF@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 02:58:17PM -0500, Chuck Lever wrote:
> Should I send you a patch?

I'm applying the following.

--b.

commit fc4ee8d8a5f7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Nov 15 11:21:40 2018 -0500

    nfsd4: zero-length WRITE should succeed
    
    Zero-length writes are legal; from 5661 section 18.32.3: "If the count
    is zero, the WRITE will succeed and return a count of zero subject to
    permissions checking".
    
    This check is unnecessary and is causing zero-length reads to return
    EINVAL.
    
    Cc: stable@vger.kernel.org
    Fixes: 3fd9557aec91 "NFSD: Refactor the generic write vector fill helper"
    Cc: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d505990dac7c..c364acbb6aba 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1016,8 +1016,6 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nvecs = svc_fill_write_vector(rqstp, write->wr_pagelist,
 				      &write->wr_head, write->wr_buflen);
-	if (!nvecs)
-		return nfserr_io;
 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
 
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
