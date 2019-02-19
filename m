Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC0CC4360F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:56:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA7E021773
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:56:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727303AbfBSQ4S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:56:18 -0500
Received: from out02.mta.xmission.com ([166.70.13.232]:40259 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726321AbfBSQ4S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 11:56:18 -0500
Received: from in01.mta.xmission.com ([166.70.13.51])
        by out02.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8gr-0004sc-CN; Tue, 19 Feb 2019 09:56:17 -0700
Received: from ip68-227-174-240.om.om.cox.net ([68.227.174.240] helo=x220.xmission.com)
        by in01.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8gq-0006os-E3; Tue, 19 Feb 2019 09:56:16 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
        <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 10:56:05 -0600
In-Reply-To: <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Fri, 15 Feb 2019 16:07:33 +0000")
Message-ID: <87h8czvhsq.fsf@xmission.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1gw8gq-0006os-E3;;;mid=<87h8czvhsq.fsf@xmission.com>;;;hst=in01.mta.xmission.com;;;ip=68.227.174.240;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+Hkz9xC2ZtoJq9WrUfQB5JLxVLoRP611w=
X-SA-Exim-Connect-IP: 68.227.174.240
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel objects
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

David Howells <dhowells@redhat.com> writes:

The container id details are ludicrous and will break practically
every use case.  This completely unacceptable.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> diff --git a/include/linux/container.h b/include/linux/container.h
> new file mode 100644
> index 000000000000..0a8918435097
> --- /dev/null
> +++ b/include/linux/container.h
> +/*
> + * The container object.
> + */
> +struct container {
> +	u64			id;		/* Container ID */
...

No.  This is absolutely unacceptable.
As this breaks breaks nested containers and process migration.

> +};
> +
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index d2f90fa92468..073a3a930514 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -36,6 +36,7 @@ struct backing_dev_info;
>  struct bio_list;
>  struct blk_plug;
>  struct cfs_rq;
> +struct container;
>  struct fs_struct;
>  struct futex_pi_state;
>  struct io_context;
> @@ -870,6 +871,8 @@ struct task_struct {
>  
>  	/* Namespaces: */
>  	struct nsproxy			*nsproxy;
> +	struct container		*container;
> +	struct list_head		container_link;

Why?  nsproxy would be a much cheaper location to put this.
Less space and less foobar.

>  	/* Signal handlers: */
>  	struct signal_struct		*signal;
> diff --git a/kernel/container.c b/kernel/container.c
> new file mode 100644
> index 000000000000..ca4012632cfa
> --- /dev/null
> +++ b/kernel/container.c
> @@ -0,0 +1,348 @@
[...]
> +
> +	c->id = atomic64_inc_return(&container_id_counter);

This id is not in a namespace, and it doesn't have enough bits
of entropy to be globally unique.   Not that 64bit is enough
to have a chance at being globablly unique.


Eric
