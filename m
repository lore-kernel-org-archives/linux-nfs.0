Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF971C433FE
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Oct 2021 14:43:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AC67761215
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Oct 2021 14:43:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240521AbhJOOpR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Oct 2021 10:45:17 -0400
Received: from out01.mta.xmission.com ([166.70.13.231]:55382 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237154AbhJOOpR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Oct 2021 10:45:17 -0400
Received: from in02.mta.xmission.com ([166.70.13.52]:48230)
        by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1mbOQP-001lT2-P8; Fri, 15 Oct 2021 08:43:09 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:36892 helo=email.xmission.com)
        by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1mbOQO-007RxG-Qp; Fri, 15 Oct 2021 08:43:09 -0600
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     Alexey Gladkov <legion@kernel.org>
Cc:     LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Sargun Dhillon <sargun@sargun.me>
References: <20211014160230.106976-1-legion@kernel.org>
Date:   Fri, 15 Oct 2021 09:43:01 -0500
In-Reply-To: <20211014160230.106976-1-legion@kernel.org> (Alexey Gladkov's
        message of "Thu, 14 Oct 2021 18:02:30 +0200")
Message-ID: <87o87qxsay.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1mbOQO-007RxG-Qp;;;mid=<87o87qxsay.fsf@disp2133>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/IMy026dG3gJOeucUGJ4SAuwgKEo298OU=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH] Fix user namespace leak
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Alexey Gladkov <legion@kernel.org> writes:

> Fixes: 61ca2c4afd9d ("NFS: Only reference user namespace from nfs4idmap struct instead of cred")
> Signed-off-by: Alexey Gladkov <legion@kernel.org>

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

nfs folks do you want to pick this up?

> ---
>  fs/nfs/nfs4idmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
> index 8d8aba305ecc..f331866dd418 100644
> --- a/fs/nfs/nfs4idmap.c
> +++ b/fs/nfs/nfs4idmap.c
> @@ -487,7 +487,7 @@ nfs_idmap_new(struct nfs_client *clp)
>  err_destroy_pipe:
>  	rpc_destroy_pipe_data(idmap->idmap_pipe);
>  err:
> -	get_user_ns(idmap->user_ns);
> +	put_user_ns(idmap->user_ns);
>  	kfree(idmap);
>  	return error;
>  }
