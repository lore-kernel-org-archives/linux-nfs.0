Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC298C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 12:49:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DE86218A1
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 12:49:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="Q+1LzVZW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728208AbfCUMtk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 08:49:40 -0400
Received: from mail-ua1-f67.google.com ([209.85.222.67]:40015 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728049AbfCUMtj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2019 08:49:39 -0400
Received: by mail-ua1-f67.google.com with SMTP id b8so1868079uaq.7
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2019 05:49:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s9ok+Yr44guhKYSdb8LvHQaRC2IkfVGVRdPbTAQdJLI=;
        b=Q+1LzVZWB8c5991yCVduyQl+3jJpIpGM3tpIBI1FDSshHha55lrw1DsKM1Yg8AoNmu
         VvyuiNm73z7Hfa5G4iLFjhsvCYgUjgZp/vnhtbaCT1nvCeNDKmGp898Xgqblvidn5N1S
         +sYw9mjZg5tPapckNjLkeSRcdj8/+zD07KFFORg8P+26NHIi1eQtM9zGiqwMf/GjVr26
         tMW25OcIWKMoMh4HcjjW6M4I226+Ux/FAoonnIvLGDibm2FnsAWb8ElNsrwh103bYA+A
         HX/0I9jegGgo4mp1iyEVznLIZitTffIOrXHBoKNMbBX9ofzpFztw7E6XUXO39Yuv/+Hb
         WG1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=s9ok+Yr44guhKYSdb8LvHQaRC2IkfVGVRdPbTAQdJLI=;
        b=DO9e9sdVWmLx5Ohyn+N7Ch34N//X4LdyIB4CFVNt55FTx1m5nwH6coB0pklfB9OYZw
         m9BkWVPFTztmJ4Nhh60hB94hDAPSyGOsGu2b7m+HtrULuGgrmwAJhxw6GKoX8WiAGzCl
         /w25HKlwT39b0hr6HzueYfde/RpGYAybH5tPdTMtvqaaLV1MSG0w3t1rIHMs85z8PCPA
         +7oO6ErKcEwofnczQLw5wg2aC01FS8zQ+YMgKN/kRyRxiKGpQkgRigGGp3yxjSrki4mm
         FV6qeT4RLVQ6y9TMk0GcN4KHp+/Z2amFxaGohcduKgKM/eMYd0ED3BSWp2MOOkVu5m6a
         ZLmg==
X-Gm-Message-State: APjAAAV4fQ0jKITZjtWbpkcYNAcN5K3xBy0sMH/fNl/sT0TDdAfUzhl5
        fraB4Xqflf9FtDA+x3wiZNVdt1W+Crb2AERW0C4=
X-Google-Smtp-Source: APXvYqxs5Du0yVMrRM/MEovVHDtMPr9vSZoTYOC+ceSddsZbl7/pDAEmfjO8/jp81pDCnc13eRU2ki4MundOrGrdMOw=
X-Received: by 2002:a9f:2a8b:: with SMTP id z11mr1680380uai.67.1553172578805;
 Thu, 21 Mar 2019 05:49:38 -0700 (PDT)
MIME-Version: 1.0
References: <CA+5eE-TWSOGs+7wJnykbwD84iTuXStgmsprxbXdf27ciHMg2Ng@mail.gmail.com>
 <CAN-5tyHO0mJfwha2z1+bFcq6+R3E1qws2p_EYJZbm93BRaS=EQ@mail.gmail.com> <CA+5eE-QZ5J5jjSvGUGj8pOHNwZfHpFnyoQd0QanqOEGLW5LpcA@mail.gmail.com>
In-Reply-To: <CA+5eE-QZ5J5jjSvGUGj8pOHNwZfHpFnyoQd0QanqOEGLW5LpcA@mail.gmail.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Thu, 21 Mar 2019 08:49:27 -0400
Message-ID: <CAN-5tyFPCLWY0J0PftdOHuA2FAYGL7VaQYdj-Xu5dQXudU=PwQ@mail.gmail.com>
Subject: Re: Some questions about Trunking
To:     Marvin Zhang <fanzier@gmail.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 20, 2019 at 11:05 PM Marvin Zhang <fanzier@gmail.com> wrote:
>
> On Wed, Mar 20, 2019 at 10:29 PM Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > This question is more of an NFSv4.1 protocol question thus I would
> > encourage you to ask it on the nfsv4@ietf.org.
> >
> > On Tue, Mar 19, 2019 at 11:06 PM Marvin Zhang <fanzier@gmail.com> wrote:
> > >
> > > Hi Experts,
> > > Here are some questions about trunking:
> > > 1.  For session trunking. During first mount(or first connection),
> > > client create a session. During the second mount(or second
> > > connection), client will reuse the session which the first connection
> > > created. Does the second mount create a new super block or reuse the
> > > previous?
> > > If there is a READ request on this session, how to judge to
> > > use which connection?
> >
> > Session trunking does not require the client to create a different
> > mount in your example. A single mount could have multiple TCP
> > connections established between a client and a server and they would
> > use the same NFSv4.1 session to send operations to the server. A read
> > operation issued by the application using the NFS mount could use one
> > of those connection and the question which one it would use is
> > protocol implementation specific. Simplest implementation round robins
> > connections for incoming RPC tasks.
> I just followed this article:
> https://packetpushers.net/multipathing-nfs4-1-kvm/ . In this article,
> client mounts the server twice in differ conections. But as you said,
> it's not session trunking. I still don't konw how to mount a server
> only once with two connection. Could you give me a sample here? I
> don't find any example in google searching result.

There was a series of patches proposed by Trond about 2 years ago that
add "nconnect=X" mount option that will create X TCP connections to
the server. You can find that series apply it and build a kernel with
that or you can use SLES15 distro where those patches were included.


>
> >
> > If the client mounted a server and then decides to mount the same
> > server again (given same mount options and credentials), in the linux
> > implementation, the existing NFS client (and its TCP connection) would
> > be re-used. Thus it would not be a case of session trunking.
> >
> > > 2. For client id truking. As protocol said, client can create multipl
> > > session at the same time. I can't understand in which scenario client
> > > can create multiple session
> >
> > Again IETF list can provide some examples and motivations for the
> > clientid case. I think perhaps it was for the clustered server
> > environment where the client would use the same client id across
> > different cluster nodes but it would establish unique sessions to the
> > nodes.
