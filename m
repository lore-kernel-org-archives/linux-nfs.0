Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFACFC43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 18:11:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1DF9120685
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 18:11:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RBqL21n2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728233AbfDYSLr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 14:11:47 -0400
Received: from mail-yb1-f193.google.com ([209.85.219.193]:37307 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726758AbfDYSLr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2019 14:11:47 -0400
Received: by mail-yb1-f193.google.com with SMTP id p134so340628ybc.4;
        Thu, 25 Apr 2019 11:11:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=oHd7Fi5DcKd5oM8boGoQwTbbekylxHPnNsnaqcBOneM=;
        b=RBqL21n2IWt5/9AMQqteMPZzJ2AV/K7r4Cv7F4JY4Hmy1WNqApBbGs8axEH276Nz0T
         iv+wY7pDqEbgjaGKyV2GsGF0Wh3RiINXDR5lTJI1Z1xcF582QyETEck53ak6gs7bumGu
         YDkQ8lavypNc16zYZJNfpyVRyJVW3gdCoMD17nuMYaRsgs0CdH9lO9iWgGRpJZNplw3u
         Q6kx0RcTd2C0x5EdYTnLf3pjv5IWsd/cqhnbSjaE5QNfchXX8kwVc5icUTcBcWtN4lYF
         9R8bDRtqACnHdOwG5kH7LudppSGbyTHzbKd0wbnfYmoEM38jK7hH1wKYJksKrBGNuICI
         eLSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=oHd7Fi5DcKd5oM8boGoQwTbbekylxHPnNsnaqcBOneM=;
        b=WZLNS9K8EsPRYnvGQm+SVJRuVuX42NpSwzGH1xhnFimLwmZyNEZsZ1Yv7xKISwdLUA
         evsAAdE95NSwx8bD/9hbaJ56jf8thLSfmasufFo+vxJOwWdSmpVVogcakaBkkW1D2u02
         ppee72/BkX2c452zpg5+kCKQ2f8g7+myKxA3KQAsreFMgLIxKX6sJaXrOscBUQJZ0TjS
         8K34aKFFrubS1Cc66k4vTDMjlfIAHJuZCmcCm2KKVs153D6nvtAjE0ZhibIaYuzolQXY
         l4Ss2Qyh28uCItwT+4gQFZuwwVlayKu8DnzJttZlkiGl9fayP4OmkHtlN7CCUJGjh8/P
         7O6g==
X-Gm-Message-State: APjAAAXevkWumtP6RtUB1qo0MLOIARjvBfQWvlEcr97hJzvc9K/jvwFy
        F8H+Mkh+Fx311ho68dAoj/zjwVCc/Yvbb7ESe06J+aUn
X-Google-Smtp-Source: APXvYqzizY4ktsfc7B83TWAYZy6fYlvHDCBCAWoisaCpCyn1ob901nn14s0koMuy/e2ZKELrkH8Qd9SKKSQGlsxJNnw=
X-Received: by 2002:a5b:48a:: with SMTP id n10mr33146015ybp.320.1556215906035;
 Thu, 25 Apr 2019 11:11:46 -0700 (PDT)
MIME-Version: 1.0
References: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3> <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
 <20190306151150.GC2426@fieldses.org> <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
 <20190306210743.GE19279@jra3> <F00A0481-0AC7-411E-8353-BF104713F524@samba.org>
 <5ebdb58b-26d9-c0f2-bd67-883bc4678ac7@samba.org>
In-Reply-To: <5ebdb58b-26d9-c0f2-bd67-883bc4678ac7@samba.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Apr 2019 21:11:34 +0300
Message-ID: <CAOQ4uxiBLw_L=SqCjLU6W60LbtWiLaBh=5Cb4HnSAFqCW0z1WA@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     Stefan Metzmacher <metze@samba.org>
Cc:     =?UTF-8?B?UmFscGggQsO2aG1l?= <slow@samba.org>,
        Jeremy Allison <jra@samba.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, devel@lists.nfs-ganesha.org,
        Jeff Layton <jlayton@kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 7, 2019 at 1:04 PM Stefan Metzmacher <metze@samba.org> wrote:
>
> Am 06.03.19 um 22:25 schrieb Ralph B=C3=B6hme via samba-technical:
> >
> > Jeremy Allison wrote:
> >> On Wed, Mar 06, 2019 at 03:31:08PM -0500, Jeff Layton wrote:
> >>> On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
> >>>>
> >>>> Jeff, wasn't there some work (on Ceph maybe?) on a userspace delegat=
ion
> >>>> API?  Is that close to what's needed?
> >>>>
> >>>
> >>> Here's the C headers for that stuff:
> >>>
> >>>    https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba=
8dd287bd/src/include/cephfs/libcephfs.h#L1734
> >>>
> >>> It's simple enough and works for us in ganesha, and I think we can
> >>> probably adapt it to samba without too much difficulty. The callback
> >>> doesn't seem like it'll do for a kernel API though -- you'd almost
> >>> certainly need to do something different there (signals? inotify?).
> >>
> >> SMB3 leases have R/RW and Handle-based leases.
> >
> > Just to be precise: SMB2.1+ has R, RH, RW and RWH leases.
> >
> >> Handle leases allow multiple opens of the same pathname
> >> that get different handles to share the lease, allowing
> >> a client redirector to delay opens or closes locally
> >> so long as it has a handle lease.
> >
> > That'a a propertly of leases in general, not just H-leases. The client =
provides a lease key which is a GUID with each lease request
> >
> >>
> >> Here are the semantics:
> >>
> >> https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/d=
8df943d-6ad7-4b30-9f58-96ae90fc6204
> >>
> >> I'm not sure a simple file-descriptor based API is
> >> enough for us. Can he have a uuid or token based
> >> API instead where the server can chose what fd's
> >> to cover with a token ?
> >
> > Yes, that would be ideal.

Getting back to this.
Thanks all for the valuable inputs.

Next week is LSF/MM and I was assigned a 30 minute slot on filesystems trac=
k
to discuss "NFS/SMB file share".

So let me try to echo what I read on this thread and how I understand what =
APIs
samba needs from the kernel.

>
> If we want to design an useful API, we also need to think about
> all features:
> - file oplock/leases

Kernel can have a flavor of leases which are not broken
by opens from threads of the process holding the lease.
Bruce has some patches along those lines for knfsd and SMB R/RW
leases could use this flavor if it was exported to userspace?

For SMB RH/RWH leases and Ganesha delegations, server
could keep track of its own handles/clients and break leases within the
same process without involving the kernel.
Am I wrong?

> - directory leases

I have WIP on fsnotify directory pre modification hooks.
There is opposition from fsnotify maintainer to add new userspace
APIs that can create kernel->user->kernel deadlocks, like the
deadlocks currently reported with fanotify permission events.

Need to see if we can find a middle ground between
"post modification notifications" and "pre modification permission"
API, somewhere along the lines of regular file lease breaking API.

> - share modes

Volker told me he thinks samba can enforce share modes by
a single daemon policing all opens in the system with fanotify.
I think he is right. If anyone thinks differently please speak up.

> - disconnected handles (for durable and persistent handles),
>   which exists within the kernel for a while and can be reattached
>   to process, using some kind of cookie and the same euid

So this interface exists in the kernel.
Nothing more required from the kernel API. Right?

> - the API needs ways to use epoll in order to do async opens
>   and lease breaks. For opens the model of async socket connects
>   could be used. Leases could have a signalfd-style api.

I should hope that the new AIO API (http://kernel.dk/io_uring.pdf)
would solve those problems as well as other issues that
samba has w.r.t dispatching AIO.

>
> We may not need everything at once, but we should have the full picture
> in mind. And we need working code in kernel and userspace that passes
> all tests (we may need to add additional test). Otherwise the kernel
> creates new syscalls, which wouldn't be used by Samba in the end.
>

Tested interfaces - good idea ;-)

If anyone has any comments about my view of required new interfaces,
or important things that I missed, please say so before Tuesday!

Thanks,
Amir.
