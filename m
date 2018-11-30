Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 129B9C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:58:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A98C620660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:58:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="pHEdT5wc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A98C620660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726885AbeLAJIq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:08:46 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:47016 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726883AbeLAJIp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:08:45 -0500
Received: by mail-vs1-f68.google.com with SMTP id r14so4218803vsc.13;
        Fri, 30 Nov 2018 13:58:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=p572XoVLzvD9c6JARAU92IHRKP2hpvyAD4lCNpY97N0=;
        b=pHEdT5wcekuku7dn/l926KZcLZaseD4zJZsOuEzBCGT9LLlJTa8gtRRV5VDP7dCzGJ
         i1e6Jp5+j5fqU5eWe94OPtm6vE5pfat/j8FH/1KBmPUWK7BS5tiysQfmaQcQJDHMtdEx
         aFI/aVMYCojp0rn5EUfQT6jhnxqpzjbXgP+9psCeCeu+eo1xqAWisuECWOjZ4RxnahOj
         /wEmsOLQS00YWQY4eT4y9wwO1J+kZjMArnc0jAS24Z7lVkJUpefDK4r8kQIwE15Rpobd
         +8JNUf+nH7pNSX+MKPLpF9NTSJI0w0rr8sNGVqfmcLRp7qPVbT6daeq0j73j5pFkux92
         tw7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=p572XoVLzvD9c6JARAU92IHRKP2hpvyAD4lCNpY97N0=;
        b=r3Hi7Qr9ckfxKfDO5nOa0saY5Z68hPl2wIi16Yadhn715//ydSd/GcvurhZQJVFZJ6
         nMoioopqDQaUuywgaCfgryV0wMmB3b9d5OrH+1cRvj3Tp5RLTQKQ/LKwFgY060Bxj7Wc
         LB23bSJ0c6YhFFcrSO9/Z9X3WijQz2IXebBNDLaa9Z1ytYZFsIQqCci4qvpNmvp4Pf1Q
         mbFlEv0q5XqF8uTxGCD4oq1d1bzo1OjmuAYVcJREI8BINswpai1dwaZHDMjBMRJA3g8o
         J1n5aYzlgHynAyqhD2Teo2eQSVfQgh0VDdrVgZitMieSg50SeSHXPIJDulmPpwYBykUD
         dpGA==
X-Gm-Message-State: AA+aEWa2KeaxitWEfRkVdc0CK3IY3iY2qCGU/AdlS3lm6yd48J9WXoUi
        0lKL6y6mEZnpnvYx8p+9JT0Q1FlhNcVnRsAgYsg=
X-Google-Smtp-Source: AFSGD/UuMDho8jPOgD8Rw85Tr3MgDODQsat9LcEriN2WUrR/1P8JHgrCWnNoCaU+21wRqs4UFbgec9bv9wb+EZvjAZc=
X-Received: by 2002:a67:a858:: with SMTP id r85mr3207191vse.215.1543615082006;
 Fri, 30 Nov 2018 13:58:02 -0800 (PST)
MIME-Version: 1.0
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
 <20181126200717.10321.8819.stgit@manet.1015granger.net> <952872188dd26c5469f4bafe5689a5b2b377803f.camel@gmail.com>
 <F9AC1596-B0F1-4F52-B798-3D94550D4560@oracle.com>
In-Reply-To: <F9AC1596-B0F1-4F52-B798-3D94550D4560@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 30 Nov 2018 16:57:48 -0500
Message-ID: <CAN-5tyFGwmTxoxj=UMLZf_UcCc6CSfaZeowo9e4iFRBCgozOQg@mail.gmail.com>
Subject: Re: [PATCH v2 17/20] SUNRPC: Remove support for kerberos_v1
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Anna Schumaker <schumaker.anna@gmail.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 4:26 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Nov 30, 2018, at 4:19 PM, Anna Schumaker <schumaker.anna@gmail.com> wrote:
> >
> > Hi Chuck,
> >
> > On Mon, 2018-11-26 at 15:07 -0500, Chuck Lever wrote:
> >> Kerberos v1 allows the selection of encryption types that are known
> >> to be insecure and are no longer widely deployed. Also there is no
> >> convenient facility for testing v1 or these enctypes, so essentially
> >> this code has been untested for some time.
> >>
> >> Note that RFC 6649 deprecates DES and Arcfour_56 in Kerberos, and
> >> RFC 8429 (October 2018) deprecates DES3 and Arcfour.
> >>
> >> Support for DES_CBC_RAW, DES_CBC_CRC, DES_CBC_MD4, DES_CBC_MD5,
> >> DES3_CBC_RAW, and ARCFOUR_HMAC encryption in the Linux kernel
> >> RPCSEC_GSS implementation is removed by this patch.
> >
> > I guess my biggest question is if any servers in the wild might still be using
> > Kerberos v1 encryption that we need to worry about?
>
> What we want to do here is remove encryption types that the upstream
> community can no longer support, and that the IETF says are insecure
> and thus should not be used (even if we could support them). IMO this
> is not a matter of continuing to support old servers: they need to
> update.

I'm not arguing for not removing it .. but.. also to consider not
necessarily the server implementations but the fact that prior to
Window 2008 AD there is no support for AES encryption types.

>
>
> > And does the rpc.gssd daemon need to be updated as well?
>
> If the kernel doesn't ask for these encryption types, gssd won't use
> them. It might do with some clean up, though, but I haven't looked
> closely at it.
>
>
> --
> Chuck Lever
>
>
>
