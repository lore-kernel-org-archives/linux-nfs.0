Return-Path: <SRS0=IhtM=DC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8FC1C4727E
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Sep 2020 20:48:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4B98620838
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Sep 2020 20:48:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="pzFaIZNI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727880AbgIYUsK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Sep 2020 16:48:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56254 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726316AbgIYUsK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2020 16:48:10 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9BDF4C0613CE
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2020 13:48:10 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id EC7D432EC; Fri, 25 Sep 2020 16:48:09 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org EC7D432EC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1601066889;
        bh=2oupUNFoCnnOBIxdD0ivFzhDSWEci1/ONMoo/zBj/dU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=pzFaIZNIzOiw/bTBHG6ddMFUvcNppV198T641P9G/sf3owAIZQpY7MM12ezgQoeUI
         ESQ9EBPJJBfC5kk3Aq46/HjI/x6Yp3vb5UaxaCJ7sp+xs3lxR+eA9cFsAFY0A52K6I
         eeOqD08eXaOytHRJcevMDDdIKO/v8BMRgG/fYGvY=
Date:   Fri, 25 Sep 2020 16:48:09 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: rq_lease_breaker cleanup
Message-ID: <20200925204809.GI1096@fieldses.org>
References: <160106058240.10141.2317053300018495103.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160106058240.10141.2317053300018495103.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Sep 25, 2020 at 03:03:42PM -0400, Chuck Lever wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Since only the v4 code cares about it, maybe it's better to leave
> rq_lease_breaker out of the common dispatch code?
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4state.c |    3 +++
>  fs/nfsd/nfs4xdr.c   |    1 +
>  fs/nfsd/nfssvc.c    |    2 --
>  3 files changed, 4 insertions(+), 2 deletions(-)
> 
> Hey Bruce-
> 
> This seems to work a little better than the patch you sent me
> this morning.

Oops, right, I should have warned that was untested!  I don't know how
it got past me that I was trying to read rqst before it was set....

The other two lines aren't needed, though.

(The only place we read rq_lease_breaker is in nfsd_breaker_owns_lease(),
and only after we've checked that we're running as an nfsd thread
processing an NFSv4 rpc.

Such a thread shouldn't touch the filesystem and trigger this callback
until it's in nfsd4_proc_compound.  Which sets rq_lease_breaker at the
start.)

--b.

commit 4abef2c530f7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Sep 25 10:12:39 2020 -0400

    nfsd: rq_lease_breaker cleanup
    
    Since only the v4 code cares about it, maybe it's better to leave
    rq_lease_breaker out of the common dispatch code?
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 62afcae18e17..c13b04718a3f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4598,6 +4598,9 @@ static bool nfsd_breaker_owns_lease(struct file_lock *fl)
 	if (!i_am_nfsd())
 		return NULL;
 	rqst = kthread_data(current);
+	/* Note rq_prog == NFS_ACL_PROGRAM is also possible: */
+	if (rqst->rq_prog != NFS_PROGRAM || rqst->rq_vers < 4)
+		return NULL;
 	clp = *(rqst->rq_lease_breaker);
 	return dl->dl_stid.sc_client == clp;
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b603dfcdd361..8d6f6f4c8b28 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -1016,7 +1016,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		*statp = rpc_garbage_args;
 		return 1;
 	}
-	rqstp->rq_lease_breaker = NULL;
 	/*
 	 * Give the xdr decoder a chance to change this if it wants
 	 * (necessary in the NFSv4.0 compound case)
