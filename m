Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE9AC32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 12:04:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 03FFE2082E
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 12:04:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QL7W1Og+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03FFE2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726098AbeKBVLu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 17:11:50 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:36227 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725935AbeKBVLu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 17:11:50 -0400
Received: by mail-vs1-f67.google.com with SMTP id v205so929200vsc.3;
        Fri, 02 Nov 2018 05:04:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc:content-transfer-encoding;
        bh=exsf4J2IdnPBu9EzWzOn+Ws8qCUEdq1mZpt8NhI1Z2Y=;
        b=QL7W1Og+HjQPVXIkZzZk2I3cmepdAQ9WNaJrvwJzKBGOUzhSFW6Zw57F8DNmEDK97O
         Cza2evNCKdPZ8F1FmYaoyWfPNtzyL4Rs79aZ6tu/CSqzePkXmCW3aujQ9jziv5Sr3MqX
         KFWWQnEydnwSlWtz2LRbUAIS4wivLi/LvdHCEWos7si9H0vJugU09h0p5Jvs0tPXOxO4
         xlN2S0D4mkq2kqpF+FSHXerCdcCv/py9ZFG0PuN8XijZg8ZGUhcU+a73rmq2cmo5QkJ4
         MVSNDwahV5IQ2Qhyp6f3CkCxZwTmYscXXXiievyk6YotGTngSvqsYG7c0OxaNsyH/if4
         mYNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:reply-to
         :from:date:message-id:subject:to:cc:content-transfer-encoding;
        bh=exsf4J2IdnPBu9EzWzOn+Ws8qCUEdq1mZpt8NhI1Z2Y=;
        b=Oke5P7GUQn//1VXX/hQS5AIE3KAr8TMwg7KZQ/+rAaiyQSn/Qq7qobO4grT9FeN+h+
         exHDatMiARd4ule9YF28RGPsoEymjiiDhUpzV/eemiEh7KFYFfMl+5YDm6GZ0ON0OOAv
         6MLQLykg2rwqRhin7aynpK1pJuPGT4T839uK/eslq0KsUaQlM8u9amyMxjdF+X3CTrC0
         eecqexGAez39Y9/5axRJCNjZGNZuoBNBZZ5iKfSg8m53RTRsu66ZY5RBjsgH5EIZCuyd
         o1CdH3J3l6zF0huVOLGLBD/GjheLVem1dsrA0uZ6DVWYuL6/p86/wE5HmAedO3SLhCPq
         xRHQ==
X-Gm-Message-State: AGRZ1gKbUwhnfGnFP9libXd/7XexPMMsssSU6BtLCKWfazMnL5uCf7oz
        IZFx/Jk02Ar66n4BCJZHrgidAAd5t5nqyesAx/0=
X-Google-Smtp-Source: AJdET5dHia7UZgsKC08fMvKUb7NEmxMVdLQ0NdXmUajYqRhCNXJAmYM3ArKGyjir4+24tPC7KAdsPBNj74Y/oxMicxI=
X-Received: by 2002:a67:f114:: with SMTP id n20mr4757624vsk.90.1541160290700;
 Fri, 02 Nov 2018 05:04:50 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia> <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard>
In-Reply-To: <20181015003139.GZ6311@dastard>
Reply-To: fdmanana@gmail.com
From:   Filipe Manana <fdmanana@gmail.com>
Date:   Fri, 2 Nov 2018 12:04:39 +0000
Message-ID: <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
To:     Dave Chinner <david@fromorbit.com>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>,
        Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        ocfs2-devel@oss.oracle.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.co=
m> wrote:
> > >
> > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > >
> > > A deduplication data corruption is exposed by fstests generic/505 on
> > > XFS.
> >
> > (and btrfs)
> >
> > Btw, the generic test I wrote was indeed numbered 505, however it was
> > never committed and there's now a generic/505 which has nothing to do
> > with deduplication.
> > So you should update the changelog to avoid confusion.
>
> What test is it now? And if it hasn't been committed, are you going
> to update it and repost as it clearly had value....

Sorry, I lost track of this.

So what was the conclusion of the thread where discussion about this
problem started?
It wasn't clear to me if a consensus was reached and got lost on that
long user space dedupe tools discussion between you and Zygo.

The test assumed a fix of rounding down the range and deduping less
bytes then requested (which ended up included in 4.19 for btrfs).

From this vfs patch it seems it was decided to return errno -EDADE instead.
Is this the final decision?

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
