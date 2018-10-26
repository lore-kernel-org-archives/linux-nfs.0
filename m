Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54852C6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:39:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 06CC02082B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:39:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="ElCscjTO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CC02082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727564AbeJ0ARX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 20:17:23 -0400
Received: from mail-vs1-f45.google.com ([209.85.217.45]:36362 "EHLO
        mail-vs1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727558AbeJ0ARW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 20:17:22 -0400
Received: by mail-vs1-f45.google.com with SMTP id c205so1069231vsd.3
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 08:39:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kR4HCqLBMEYPWdT6WEq0zmEAb/rphf5EZb1tFpCPvoc=;
        b=ElCscjTO7n23HtPu/FKTwjX37wXA9afHgF0iFArSvFD8DSLlwEanfIozq20yCGplN5
         leMVSaE6RWfrmY1eEXGIBhAUTsX0u1um9/ucUWly85+v4sUShdwBYsGCAdHmG9i6TNM0
         q1Rk6UxwVMqOlqAXMKqXZ+TKIygwJlmpcaop1l68c28mLFdj+0QVOUFflUhfoZG8onId
         NRZT0ABSrcEt52md4fjnyjxD+vUOvSkIR4f2cQ21jp65xOZmuGfVnFXZfw+cpRTaah07
         eaylzpZDd0QSUL4hwY5MsoFnI+wneDDlMQw+coC/sEEU/oNuPclr1TUgwPUrOMzn6uSt
         FBIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=kR4HCqLBMEYPWdT6WEq0zmEAb/rphf5EZb1tFpCPvoc=;
        b=SRdJvFhUBZPjF+Q7IW0c4DalP95uW6opOOYaRW5sGE/WworeRD4MVrYbTT+q/ntGCh
         G5x58B+309ZkM2gSziCRu0usegCJkrdU7Z+K5TWIt1G7zU7gH7MPQBPsBhtcOqsgSXor
         10iaod3Mi3pbxcfU1y8cvXUJchkd+1aTi5H2CfCc2G51/Il4SE/zLmLnDwDtDeENoO95
         vhEuEeIBN5KzEYKi2pfflfJQP8naVpUB+pfIol/wZWLV0ccQh00MPFXmQKSrlNY4wQbz
         p6Ty031uri/mSBnHgAf9AaKOc7I35QKNHblGmVeDYNed01E9iHQZe+EdWl6GfXdUkgM8
         jJWA==
X-Gm-Message-State: AGRZ1gKhsaTjri5Q4oZVmJJPsbEKGXLXkRgzss9b6cHi1WBvNaUWhotN
        8e2wk4fRM16SJkTBKxNZypcAGusNj3t80FDrg1h4pmUg
X-Google-Smtp-Source: AJdET5fUCcUtSUdyMRpDv9pFQg+JGmrR1xgreukDUBdFjdP9laWbWoCa3/Bd0747nBq/phSs9GtO88DuPvZZUhyPdOk=
X-Received: by 2002:a67:f441:: with SMTP id r1mr1742722vsn.164.1540568390643;
 Fri, 26 Oct 2018 08:39:50 -0700 (PDT)
MIME-Version: 1.0
References: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
 <6CA0FBE4-6B7C-4D05-BE1E-AB3BEDD90171@oracle.com>
In-Reply-To: <6CA0FBE4-6B7C-4D05-BE1E-AB3BEDD90171@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 26 Oct 2018 11:39:38 -0400
Message-ID: <CAN-5tyE25JYUbnhvRD32_ZxyALdXd+emy2qK315DeXb+DgLn1Q@mail.gmail.com>
Subject: Re: copy offload support and absent file system
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 11:04 AM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Oct 26, 2018, at 8:54 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > Hi Chuck,
> >
> > In the context of doing a copy between different "types" of
> > filesystems, it was pointed out to me that NFS has many types:
> > nfs4_fs_type, nfs4_remote_fs_type, nfs4_remote_referral_fs_type,
> > nfs4_referral_fs_type. So doing a simple check that fs type of "in"
> > and "out" might not be sufficient. Do you see any issues allowing a
> > copy offload between different types? Basically checking that "in" and
> > "out" descriptions come from any of the these types?
>
> I'm no expert... so what follows is an uninformed opinion.

I was wondering if there was anything different about the
migrated/replicated filesystem that maybe say they are typically
read-only and thus doing a copy there wouldn't be appropriate. But it
sounds like you don't see anything special about doing a copy from
nfs4_fs_type to say nfs_remote_fs_type?

> All of these are NFSv4 file systems. But I don't think that's an
> adequate check (it's necessary, but not sufficient).


> The minor version of the mount point has to be 2 or higher, and
> the client must confirm that the mounted server supports copy
> offload (because all NFSv4.2 features are OPTIONAL).

I agree that we should check for 4.2 versioning but the latter I don't
think is necessary, as the COPY call will just gets not supported
error (we already have the capability check for CAP_COPY inside of
nfs42_proc_copy , just in case we already sent one copy and then
negated the capabilities).

>
>
> --
> Chuck Lever
>
>
>
