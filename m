Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D42F1C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:35:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A19F320578
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:35:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZwBHBCTb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387563AbeLQPeu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 10:34:50 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:36595 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1733263AbeLQPeu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 10:34:50 -0500
Received: by mail-io1-f67.google.com with SMTP id m19so10300541ioh.3;
        Mon, 17 Dec 2018 07:34:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=o3yta6o3a1mOpOF4OvizI/sDaUomBC7RjDfTsS505N8=;
        b=ZwBHBCTbX25hxswuOgsvHRQzVNfuyrGcBDQpo7pjmumKKJr+qrWwNmDLfa4pPRiyO/
         5+28atb+7uEoX3kaOTJ7enfljBIohrKWDen/mNFMXyXzQOVwq+puq2hMTV/8uOPCPcVd
         p9Mw6ibXPQoGCa3FsSpl6LotM9worTSiSeZT2BsRRKtHF8ez1pCO2NGyxQ8BQmrvrdcH
         H9nw9Tdtn5VPKzJSn25aD/4Um3qfrcrBniDiWpTwOxPSF5EMbmzeYZ/bALq8PSkXfxh2
         WnWccofhD2/U50sc+FtPx+CU5U/fGiQtlIavr1DIOH7ZTXnO2sjOMOBvEp34wQZSI9oV
         vJ/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=o3yta6o3a1mOpOF4OvizI/sDaUomBC7RjDfTsS505N8=;
        b=iLR0feV8iGXh4rBT/BUBevHjqkG46GcJ0Jr+w+QsycvPKLxsa9khJsCNsHcg2OUcB7
         kfOFfuxpBOuqo8eoSKG1wV/w5gahjHZ7Id5WX5JuppZ7gLrRCaWOw2JHClctK9LdabnN
         SFt26Dorqbw4wFAO86iUfWJYBSANYxP+c47mlx/k5KgNzgsuqK8NpBSBOeok9phc/a3m
         d5YyOkokbPOR5K3f2W5Em0qiBlayVcf59BIKuh15Q7g/zsimT8RJU0hDacblp8p8euHB
         NW6QEw5Opu6IkpSoJQfcIC/zU/s/PrnxahsF9Plk48LQmZS+zmdAj/ex/zpJyrYPGli+
         awBQ==
X-Gm-Message-State: AA+aEWbOX2YpMCRshqjgCL6uoVcRkaStkmQWEFFxKVr6wm4c4l74dPuH
        iYUB/FzVdEZB0vALumAW/YE=
X-Google-Smtp-Source: AFSGD/UPo6jbL47O2kjiGhWdqRlGijee+EdCJ4RYdmImta9T4R9RB6SVhmdFKTI6rzAEWbARJdDUMw==
X-Received: by 2002:a6b:6504:: with SMTP id z4mr12190888iob.55.1545060889311;
        Mon, 17 Dec 2018 07:34:49 -0800 (PST)
Received: from gouda.nowheycreamery.com (99-9-112-69.lightspeed.livnmi.sbcglobal.net. [99.9.112.69])
        by smtp.googlemail.com with ESMTPSA id r85sm5744362iod.13.2018.12.17.07.34.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 07:34:48 -0800 (PST)
Message-ID: <33a779e0263e28976ce14cd8c1406851134cfec9.camel@gmail.com>
Subject: Re: linux-next: build failure after merge of the nfs-anna tree
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc:     Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date:   Mon, 17 Dec 2018 10:34:47 -0500
In-Reply-To: <809c5ec8-0763-6855-bbbc-3cb95e168278@rasmusvillemoes.dk>
References: <20181217101630.292dd55e@canb.auug.org.au>
         <809c5ec8-0763-6855-bbbc-3cb95e168278@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-12-17 at 12:18 +0100, Rasmus Villemoes wrote:
> On 17/12/2018 00.16, Stephen Rothwell wrote:
> > Hi all,
> > 
> > After merging the nfs-anna tree, today's linux-next build (arm
> > multi_v7_defconfig) failed like this:
> > 
> > /home/sfr/next/next/fs/nfs/nfsroot.c: In function 'root_nfs_data':
> > /home/sfr/next/next/fs/nfs/nfsroot.c:264:5: error: implicit declaration of
> > function 'fmtcheck'; did you mean 'dst_check'? [-Werror=implicit-function-
> > declaration]
> >      fmtcheck(tmp, "%s", 0), utsname()->nodename);
> >      ^~~~~~~~
> >      dst_check
> > 
> > Caused by commit
> > 
> >   66ab6f062d96 ("nfs: use fmtcheck() in root_nfs_data")
> 
> I didn't know anybody had picked that one up. It's completely safe to
> just ignore that commit until the fmtcheck() utility is actually in.
> 
> Anna, can I take the fact that this was picked up as a sort-of implicit
> ack, that I can use if and when I ever get around to resending the
> fmtcheck() series? And for simplicitly, would you mind if the nfs patch
> would just be routed along with the patches introducing fmtcheck()?

Sure that sounds good.  I'll remove it from my tree for now.

> 
> Rasmus
> 
> 

