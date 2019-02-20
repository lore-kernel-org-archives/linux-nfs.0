Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC651C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:54:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92E8B2146E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:54:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s7E0osEA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726888AbfBTSya (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 13:54:30 -0500
Received: from mail-pg1-f195.google.com ([209.85.215.195]:40872 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726074AbfBTSya (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 13:54:30 -0500
Received: by mail-pg1-f195.google.com with SMTP id u9so8788022pgo.7;
        Wed, 20 Feb 2019 10:54:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=69pGSLtiMeij6RrqmuPcnfvevvsbPQnAzvM0pX/lRJQ=;
        b=s7E0osEAFwsHekLYnw/y3dlP7Il7WkaQAXshiisgS12vLkdvmZleHZ+T2YF+DtdsmJ
         Kt9Q1+xLCHXKgZoD08EQLnHscRc2Y0LkF3sTB8idSGQrPVr4I1dvV2koHBYgFO6VJ88Q
         Ooo87w1aXfcQ53CYCvVCN83wDa9aYk35s3+ZKIf1ZOqnteFcvI010F8s2WDDAJCNFiFS
         Ug0WMtR8+QH0GE5y/2OfOh1UCuBYszTnOwyWi+Eif21ROJfD+CJ3C8o1lBxwWd1ORKMk
         iEzdZ8P0QMATmlzg9/fGhXeJBgjEAzwgYmR+/7QeUumexwkX1LrM/idRUyYSeAgqLQ7z
         EFLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=69pGSLtiMeij6RrqmuPcnfvevvsbPQnAzvM0pX/lRJQ=;
        b=PY3lAuQI+CDC8FyxT2ymI0E9Ijh/CSvIxfkGgSkthaJ8M33Ei6f9uLT1XU8kXEL+b6
         4HGrOW3RVTDtvDEaJ+BanuNJA1W8GiVBr93cu3c8/y22vTlWgzrFGvZeCAmmOWggNFSa
         zXW6geUSUZclmmdkv+jKVJB/WtLJ6tAo9OnTJAf6btQkMU2usW0prVHVHCcDGA2R3QfE
         QViP/5HnsTphD/PClA7xGRgC547AVzKB9qwWqbJhhPD8bVmgmixSgxrLdGyCwEqw0Zrs
         oldtyxm0p+eFMTsJUnv8JHoXrmoMh8u6UNIZ2qDh4+AkqhYnDoBd9sJ4+SvO9SM4pUu0
         J+uA==
X-Gm-Message-State: AHQUAuZLHJPmabKwv90RCLUQ7FUgdAzyVXfUlFXHeQZweWJTp+3OQaWe
        VK/EwPZA6i+kXOxmsPQkRDtzbfin47aqeVE5xiU=
X-Google-Smtp-Source: AHgI3IYijhMPcSrLGWJB49zHSbNC3Rl83F7L9YOfWRVl7jTC04ZbxDqJVh+kb4Oz+GXpDTyvopcjLr3AH0gWVHuOFcE=
X-Received: by 2002:a63:8743:: with SMTP id i64mr30503042pge.69.1550688868538;
 Wed, 20 Feb 2019 10:54:28 -0800 (PST)
MIME-Version: 1.0
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <8736ojybw7.fsf@xmission.com> <22055.1550619729@warthog.procyon.org.uk>
In-Reply-To: <22055.1550619729@warthog.procyon.org.uk>
From:   Steve French <smfrench@gmail.com>
Date:   Wed, 20 Feb 2019 12:54:17 -0600
Message-ID: <CAH2r5muChuoHAM-AhBhTRkp=Lz0onyPa63MpV0qgm1TQKF=R5Q@mail.gmail.com>
Subject: Re: [RFC PATCH 00/27] Containers and using authenticated filesystems
To:     David Howells <dhowells@redhat.com>
Cc:     "Eric W. Biederman" <ebiederm@xmission.com>,
        keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        Steve French <sfrench@samba.org>,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        CIFS <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, rgb@redhat.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 19, 2019 at 5:42 PM David Howells <dhowells@redhat.com> wrote:
>
> Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> > So you missed the main mailing lists for discussion of this kind of
> > thing
>
> Yeah, sorry about that.  I was primarily aiming it at Trond and Steve as I'd
> like to consider how to go about interpolating request_key() into NFS and CIFS
> so that they can make use of the key-related facilities that this makes
> available with AFS.

I am interested in this discussion because I have gotten various questions
about using Containers better on SMB3 mounts, and the question about
doing request_key better comes up **a lot** on SMB3 mounts (not just
for kerberos, Active Directory), and usability could be improved of some
of the cifs-utils that cifs.ko depends on.

Note that various virtualization/container identify features were added to the
protocol a few years ago (which we don't yet implement in Linux) but which
probably be **very** useful to followup on how these could be exposed
to help containers on network mounts in Linux.    See in particular this
new protocol feature (implemented by various servers including Windows
but not by Linux client yet) described in the protocol spec (MS-SMB2 section
2.2.9.2.1) - the "SMB2_REMOTED_IDENTITY_TREE_CONNECT context"
which can be sent at mount time:
https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/ee7ff411-93e0-484f-9f73-31916fee4cb8

This may be of interest to Samba server developers as well

> > and the maintainer.
>
> That would be me.  I maintain keyrings.


-- 
Thanks,

Steve
