Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CB5AC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 11:18:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 15C502145D
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 11:18:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="eOorp8Zs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731749AbeLQLSF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 06:18:05 -0500
Received: from mail-ed1-f65.google.com ([209.85.208.65]:46053 "EHLO
        mail-ed1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726982AbeLQLSF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 06:18:05 -0500
Received: by mail-ed1-f65.google.com with SMTP id d39so10357883edb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 03:18:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=COmzxlDd/xZKdGgwu4t9s+hxkQL6DuU2M+1Bc0sjYCw=;
        b=eOorp8ZsIxfZ7ogLNNFZF+x83Oe4d9QaNnAYq0hV8uuU0KNHdNQXyMDXGuJa0maCo7
         iJ/O+izzm27UzE8DSZewvxBINHDH60/egPRMM1jJQPAr9MpOeGaW3eCKOcBn3yyIPU0W
         i587+Q5dMmrgROR1PB9LQYFiyhc2CL5RoloY0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=COmzxlDd/xZKdGgwu4t9s+hxkQL6DuU2M+1Bc0sjYCw=;
        b=iIGGBBQkQH34fqvQ2owahX2zw3iF1i5CCl0dp+Bc9gSVQMlPLCr1AQcTlJXDItR2VF
         /VtohFUtZCpxMz2jKcgkNDHWdr5LJTUhuJtgS8FakbKI7vVCH4MIqB6PrLnExzBLHcKB
         1ldGMrXAweXHpV+OEw06bMKUF7d3lk53aiJJOlPKk/73qRgtrAxru3QQ2K7msEUVpqdb
         qubtJWw1gBi6GzCD8yxeTQyh617HJw3irA2Dz3uqB9Mozn5Ej2b15cpCagnDscIpgXcl
         LBSNWa5NnEm5LU5fpzPkBo0VNk9qSVHC6tu09Txed0LtZh/WhdY/1npG9+/W1QHCb+Hg
         pxkQ==
X-Gm-Message-State: AA+aEWZvMFIgtT5zEen1ScajULT+DOcj9XPZ2GjIseDHO1ZlFOXNrlmr
        Q6+VP3lk4ngkC+VTRFiV5dBdSA==
X-Google-Smtp-Source: AFSGD/XWswHIl7kPJXfO+ToqpeAjnYZdGeotQyj3+D2mW+9oRnCF2mbkRFtlUlXDHp1e38hXH6ONmQ==
X-Received: by 2002:a05:6402:1816:: with SMTP id g22mr7968147edy.191.1545045483151;
        Mon, 17 Dec 2018 03:18:03 -0800 (PST)
Received: from [172.26.254.248] ([193.47.71.171])
        by smtp.gmail.com with ESMTPSA id t9sm3551163edd.25.2018.12.17.03.18.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 03:18:02 -0800 (PST)
Subject: Re: linux-next: build failure after merge of the nfs-anna tree
To:     Stephen Rothwell <sfr@canb.auug.org.au>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20181217101630.292dd55e@canb.auug.org.au>
From:   Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <809c5ec8-0763-6855-bbbc-3cb95e168278@rasmusvillemoes.dk>
Date:   Mon, 17 Dec 2018 12:18:01 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20181217101630.292dd55e@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 17/12/2018 00.16, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the nfs-anna tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> /home/sfr/next/next/fs/nfs/nfsroot.c: In function 'root_nfs_data':
> /home/sfr/next/next/fs/nfs/nfsroot.c:264:5: error: implicit declaration of function 'fmtcheck'; did you mean 'dst_check'? [-Werror=implicit-function-declaration]
>      fmtcheck(tmp, "%s", 0), utsname()->nodename);
>      ^~~~~~~~
>      dst_check
> 
> Caused by commit
> 
>   66ab6f062d96 ("nfs: use fmtcheck() in root_nfs_data")

I didn't know anybody had picked that one up. It's completely safe to
just ignore that commit until the fmtcheck() utility is actually in.

Anna, can I take the fact that this was picked up as a sort-of implicit
ack, that I can use if and when I ever get around to resending the
fmtcheck() series? And for simplicitly, would you mind if the nfs patch
would just be routed along with the patches introducing fmtcheck()?

Rasmus


