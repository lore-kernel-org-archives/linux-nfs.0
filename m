Return-Path: <SRS0=FZjK=ZO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC9BC432C0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Nov 2019 15:50:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E478C20714
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Nov 2019 15:50:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="glNr5OHF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726698AbfKVPuN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Nov 2019 10:50:13 -0500
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:31252 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726633AbfKVPuN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Nov 2019 10:50:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1574437812;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=Vmg1nzlJHPLlNq9iO/jybb+sA7oa7LyeIyRwZYKhNPc=;
        b=glNr5OHFnG15z7QGFKJOmDgbqoJMAaXTU9AhHJsy6Jg68tLLRLFG6h8fg6rTvlcig2l9xf
        nk97F1zw+lGzYvTbq0y3VhqI5AmIbB0vjPHHhdNQL5c2EyAGRguRQzsUFepAdWAn+hqyz5
        uhntrh8evP7G+XZhlQqMMXKHliOU260=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-221-6M3D3jyONfC6DWmTB4rz2A-1; Fri, 22 Nov 2019 10:50:08 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 213EE800054;
        Fri, 22 Nov 2019 15:50:07 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-117-36.phx2.redhat.com [10.3.117.36])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8711C5DDB2;
        Fri, 22 Nov 2019 15:50:06 +0000 (UTC)
Subject: Re: [PATCH] nfsdcld: Fix printf format strings on 32bit
To:     Doug Nazar <nazard@nazar.ca>, linux-nfs@vger.kernel.org
References: <20191119230920.10994-1-nazard@nazar.ca>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <e66b050b-4d09-891c-3630-29d6dbb21f8b@RedHat.com>
Date:   Fri, 22 Nov 2019 10:50:06 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.1.1
MIME-Version: 1.0
In-Reply-To: <20191119230920.10994-1-nazard@nazar.ca>
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-MC-Unique: 6M3D3jyONfC6DWmTB4rz2A-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/19/19 6:09 PM, Doug Nazar wrote:
> Signed-off-by: Doug Nazar <nazard@nazar.ca>
Committed... (tag: nfs-utils-2-4-3-rc2)

steved.
> ---
>  utils/nfsdcld/nfsdcld.c | 14 +++++++-------
>  utils/nfsdcld/sqlite.c  |  6 +++---
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> index b064336d..9297df51 100644
> --- a/utils/nfsdcld/nfsdcld.c
> +++ b/utils/nfsdcld/nfsdcld.c
> @@ -378,7 +378,7 @@ cld_not_implemented(struct cld_client *clnt)
>  	bsize = cld_message_size(cmsg);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize)
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  
>  	/* reopen pipe, just to be sure */
> @@ -409,7 +409,7 @@ cld_get_version(struct cld_client *clnt)
>  	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> @@ -459,7 +459,7 @@ reply:
>  	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> @@ -498,7 +498,7 @@ reply:
>  			cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> @@ -548,7 +548,7 @@ reply:
>  			cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> @@ -607,7 +607,7 @@ reply:
>  	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> @@ -667,7 +667,7 @@ reply:
>  	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
>  	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
>  	if (wsize != bsize) {
> -		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
> +		xlog(L_ERROR, "%s: problem writing to cld pipe (%zd): %m",
>  			 __func__, wsize);
>  		ret = cld_pipe_open(clnt);
>  		if (ret) {
> diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
> index 23be7971..09518e22 100644
> --- a/utils/nfsdcld/sqlite.c
> +++ b/utils/nfsdcld/sqlite.c
> @@ -512,7 +512,7 @@ sqlite_startup_query_grace(void)
>  	current_epoch = tcur;
>  	recovery_epoch = trec;
>  	ret = 0;
> -	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
> +	xlog(D_GENERAL, "%s: current_epoch=%"PRIu64" recovery_epoch=%"PRIu64,
>  		__func__, current_epoch, recovery_epoch);
>  out:
>  	sqlite3_finalize(stmt);
> @@ -1223,7 +1223,7 @@ sqlite_grace_start(void)
>  
>  	current_epoch = tcur;
>  	recovery_epoch = trec;
> -	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
> +	xlog(D_GENERAL, "%s: current_epoch=%"PRIu64" recovery_epoch=%"PRIu64,
>  		__func__, current_epoch, recovery_epoch);
>  
>  out:
> @@ -1282,7 +1282,7 @@ sqlite_grace_done(void)
>  	}
>  
>  	recovery_epoch = 0;
> -	xlog(D_GENERAL, "%s: current_epoch=%lu recovery_epoch=%lu",
> +	xlog(D_GENERAL, "%s: current_epoch=%"PRIu64" recovery_epoch=%"PRIu64,
>  		__func__, current_epoch, recovery_epoch);
>  
>  out:
> 

