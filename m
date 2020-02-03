Return-Path: <SRS0=+7wx=3X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1920BC33CAC
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Feb 2020 14:22:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D45382082E
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Feb 2020 14:22:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="FCk2MCD2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728059AbgBCOW2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Feb 2020 09:22:28 -0500
Received: from us-smtp-2.mimecast.com ([207.211.31.81]:26387 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727830AbgBCOW2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2020 09:22:28 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1580739747;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=qbkYCWeftWJMsx9+tYjRuDhA2q9w+ZDbpACjvzT72sg=;
        b=FCk2MCD2xX/yzy3lozrOprnCJhQxmV9KJCkjWBWSYu0cFxCS+mo1IRrNGcZOTUAlXzV39I
        m614O+cHl5hJffn+j/zNlKWk/8GknYyCrCuTM9CbQCiBxjtKIdzZYBT/I6p2V2Nf3/qiHj
        3zyJqryiezTKWw1T/s9TQJbqIdVR+aE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-115-KTw8r7vFMe-k8Uz3DiDjSQ-1; Mon, 03 Feb 2020 09:22:25 -0500
X-MC-Unique: KTw8r7vFMe-k8Uz3DiDjSQ-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 8F5FF18C43CC;
        Mon,  3 Feb 2020 14:22:24 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 2F1031001B0B;
        Mon,  3 Feb 2020 14:22:24 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@gmail.com>
Cc:     "Anna Schumaker" <Anna.Schumaker@netapp.com>,
        "Dai Ngo" <dai.ngo@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFS: Use kmemdup_nul() in nfs_readdir_make_qstr()
Date:   Mon, 03 Feb 2020 09:22:23 -0500
Message-ID: <1FED506F-5AC1-4418-8989-B139B05B8F90@redhat.com>
In-Reply-To: <20200202225356.995080-4-trond.myklebust@hammerspace.com>
References: <20200202225356.995080-1-trond.myklebust@hammerspace.com>
 <20200202225356.995080-2-trond.myklebust@hammerspace.com>
 <20200202225356.995080-3-trond.myklebust@hammerspace.com>
 <20200202225356.995080-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2 Feb 2020, at 17:53, Trond Myklebust wrote:

> The directory strings stored in the readdir cache may be used with
> printk(), so it is better to ensure they are nul-terminated.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/dir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 90467b44ec13..60387dec9032 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -199,7 +199,7 @@ static
>  int nfs_readdir_make_qstr(struct qstr *string, const char *name, 
> unsigned int len)
>  {
>  	string->len = len;
> -	string->name = kmemdup(name, len, GFP_KERNEL);
> +	string->name = kmemdup_nul(name, len, GFP_KERNEL);
>  	if (string->name == NULL)
>  		return -ENOMEM;
>  	/*

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben

