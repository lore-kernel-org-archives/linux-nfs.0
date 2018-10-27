Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08A16C46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:14:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0F0020856
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:14:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0F0020856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728547AbeJ0TzF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 15:55:05 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:45206 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728503AbeJ0TzF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 15:55:05 -0400
Received: by mail-qt1-f196.google.com with SMTP id l9-v6so4149409qtj.12
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2018 04:14:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=CQ4cPHjJhatxs6BoRVMLlK5V67AqofR868n39hGAWvc=;
        b=IaglutVijaxvpslKK9IPW7mjNJ3q/ICr2tuilFQ/O3q1T83qh91qHXoY7mXHJ/LNT/
         x50unYUP36dgPBg2xU7/7MuDLT8HbGogGjOsIIYU5Wvo0adwFBAkmqr1CGv19beuTSbQ
         +SlarWQX+O6x46lYIL2mSuZh4BfHGfRZeu9SSuOevibZS8ONjg3Taa+gqU7F30BtIIWx
         koUse5N4y+GrV/DJP4wmc9ShIx1XmXMTY7JXgzSkz2Uaw/mJR+LmeS9pzLNAe25EwmO2
         zl+90STsk+y9U60NsIOzusPCsLBp8WL5ZCGutXzx9Qbylll192CrlIbDxo7R5H5VBBda
         QEMA==
X-Gm-Message-State: AGRZ1gJRp4eP9415OUDx6POZtaWKsZtEv30mQP7DhNjRmLBkv9ZwP9v5
        wU5gqUn18nZOz4C61msX4wZ86A==
X-Google-Smtp-Source: AJdET5dd1bvNK7EInRA+8YKJSuQnt3t0Zoh0G3ZyQpc2jHN8uC+6I54XqLW7E9stbbEvXjRwsTPPoA==
X-Received: by 2002:a0c:f905:: with SMTP id v5mr6547232qvn.240.1540638868029;
        Sat, 27 Oct 2018 04:14:28 -0700 (PDT)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-43E.dyn6.twc.com. [2606:a000:1100:db::43e])
        by smtp.gmail.com with ESMTPSA id y33-v6sm11988434qth.3.2018.10.27.04.14.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 27 Oct 2018 04:14:27 -0700 (PDT)
Message-ID: <b40f7fda3213c3f0c317386bb357d12ffb6d926a.camel@redhat.com>
Subject: Re: [PATCH v4 03/11] NFS: NFSD defining nl4_servers structure
 needed by both
From:   Jeff Layton <jlayton@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Date:   Sat, 27 Oct 2018 07:14:26 -0400
In-Reply-To: <20181026201057.36899-5-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
         <20181026201057.36899-5-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-26 at 16:10 -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> These structures are needed by COPY_NOTIFY on the client and needed
> by the nfsd as well
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  include/linux/nfs4.h | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 1b06f0b..4d76f87 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -16,6 +16,7 @@
>  #include <linux/list.h>
>  #include <linux/uidgid.h>
>  #include <uapi/linux/nfs4.h>
> +#include <linux/sunrpc/msg_prot.h>
>  
>  enum nfs4_acl_whotype {
>  	NFS4_ACL_WHO_NAMED = 0,
> @@ -672,4 +673,27 @@ struct nfs4_op_map {
>  	} u;
>  };
>  
> +struct nfs42_netaddr {
> +	char		netid[RPCBIND_MAXNETIDLEN];
> +	char		addr[RPCBIND_MAXUADDRLEN + 1];
> +	u32		netid_len;
> +	u32 addr_len;

Could you fix the indentation above?

> +};
> +
> +enum netloc_type4 {
> +	NL4_NAME		= 1,
> +	NL4_URL			= 2,
> +	NL4_NETADDR		= 3,
> +};
> +
> +struct nl4_server {
> +	enum netloc_type4	nl4_type;
> +	union {
> +		struct { /* NL4_NAME, NL4_URL */
> +			int	nl4_str_sz;
> +			char	nl4_str[NFS4_OPAQUE_LIMIT + 1];
> +		};
> +		struct nfs42_netaddr	nl4_addr; /* NL4_NETADDR */
> +	} u;
> +};
>  #endif

Otherwise, looks fine.

Reviewed-by: Jeff Layton <jlayton@redhat.com>

