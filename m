Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 259D5C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:29:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C2BAD20657
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 14:29:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XVTkSLVz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2BAD20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727041AbeJ2XR7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 19:17:59 -0400
Received: from mail-vk1-f195.google.com ([209.85.221.195]:36261 "EHLO
        mail-vk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726094AbeJ2XR7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 19:17:59 -0400
Received: by mail-vk1-f195.google.com with SMTP id d141so2092647vke.3;
        Mon, 29 Oct 2018 07:29:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=47jajwE7wjqGhI98OGprsuyMEb9K7sPRMMJP8xzjbIU=;
        b=XVTkSLVzGs/nRczK6O6B+KjaDRm6urGFCQl8Fste/wrUoXq76k1jnHSlm9R1ebebc9
         xlccCxvA+CTbK7Bx5UMbpUoY8lqP0kJV2qEy+NbrTHTyevcrQ7tXczfoHuRcaFMp4++c
         RcSeWunk8gWidbyzzHZp/LtgDnkEi8QOdzfQl+By/wUXAt/GvwUYE9J+13iiSnxigQmy
         wX79/tEHIEyngpA3b5hTdAAKgxWpKOuZQ+vAK+RDmZdGuiixxx6XBLsSbwGp6rOdLBr/
         MuqBSUyoa0Tuya7oxF1TZ3PCr8Xy3KzhGeCzeFNrQefti/zkt0sB8JDwLDTJF8/A7FHY
         whFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=47jajwE7wjqGhI98OGprsuyMEb9K7sPRMMJP8xzjbIU=;
        b=WZzYOhl3A7JE65MEW/pmF101iCpPlQ4vyO9oCTdPFTdpUOwm9Nu6vFxJjDKj/0YcgO
         O1oPGDgfV9g/EQrudx7klZlGkBFvV9jHdXT73V1YhN3QlZPu5RkPl/mCs+1MeLTQrKnj
         HUVg9IeGuojRuhQpq1Q60n0tvyL5srRQ5rO6z0GRWnD5Fi/ghzXGjqkCG1C73SBc1Xtn
         oAul4cDhsacQ17MM04spBhj9PJRb1q4X3DVt73GhhYHcl+UAY5touiEvTbtKnklXijj3
         UBvmx+ajf1AlaPlwYj7tVTz3p7row7nCNYxYCpUlfQI6mAEt14qn78q0u0+tyfQckX5/
         rRoA==
X-Gm-Message-State: AGRZ1gIg7yaP2vGJQtwxbiXsolBDwVd0PYsxAXaMK/IArev+d+secH4i
        +3LuwmDIgAuFK+qrJTk/1ERFMic+aHR73yK6huSGKw==
X-Google-Smtp-Source: AJdET5fLRFVic2zSHBF1k48HS2YgC395pXbWOJNVSq+LmlC+cvAfuTmRv1rU4UYzbOBRZoMH5H1WJgcoEl8Kfri0WCU=
X-Received: by 2002:a1f:95d1:: with SMTP id x200-v6mr6050888vkd.33.1540823345143;
 Mon, 29 Oct 2018 07:29:05 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-5-olga.kornievskaia@gmail.com> <b40f7fda3213c3f0c317386bb357d12ffb6d926a.camel@redhat.com>
In-Reply-To: <b40f7fda3213c3f0c317386bb357d12ffb6d926a.camel@redhat.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 10:28:53 -0400
Message-ID: <CAN-5tyEBFzM6vrMdAqo1amOfmdPoVpD3wvTtMnALMOa4EtuhhA@mail.gmail.com>
Subject: Re: [PATCH v4 03/11] NFS: NFSD defining nl4_servers structure needed
 by both
To:     Jeff Layton <jlayton@redhat.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 27, 2018 at 7:14 AM Jeff Layton <jlayton@redhat.com> wrote:
>
> On Fri, 2018-10-26 at 16:10 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > These structures are needed by COPY_NOTIFY on the client and needed
> > by the nfsd as well
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  include/linux/nfs4.h | 24 ++++++++++++++++++++++++
> >  1 file changed, 24 insertions(+)
> >
> > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > index 1b06f0b..4d76f87 100644
> > --- a/include/linux/nfs4.h
> > +++ b/include/linux/nfs4.h
> > @@ -16,6 +16,7 @@
> >  #include <linux/list.h>
> >  #include <linux/uidgid.h>
> >  #include <uapi/linux/nfs4.h>
> > +#include <linux/sunrpc/msg_prot.h>
> >
> >  enum nfs4_acl_whotype {
> >       NFS4_ACL_WHO_NAMED = 0,
> > @@ -672,4 +673,27 @@ struct nfs4_op_map {
> >       } u;
> >  };
> >
> > +struct nfs42_netaddr {
> > +     char            netid[RPCBIND_MAXNETIDLEN];
> > +     char            addr[RPCBIND_MAXUADDRLEN + 1];
> > +     u32             netid_len;
> > +     u32 addr_len;
>
> Could you fix the indentation above?

Will do.

>
> > +};
> > +
> > +enum netloc_type4 {
> > +     NL4_NAME                = 1,
> > +     NL4_URL                 = 2,
> > +     NL4_NETADDR             = 3,
> > +};
> > +
> > +struct nl4_server {
> > +     enum netloc_type4       nl4_type;
> > +     union {
> > +             struct { /* NL4_NAME, NL4_URL */
> > +                     int     nl4_str_sz;
> > +                     char    nl4_str[NFS4_OPAQUE_LIMIT + 1];
> > +             };
> > +             struct nfs42_netaddr    nl4_addr; /* NL4_NETADDR */
> > +     } u;
> > +};
> >  #endif
>
> Otherwise, looks fine.
>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
>
