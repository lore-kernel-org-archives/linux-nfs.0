Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A5C0C67839
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 05:11:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D3EE206BA
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 05:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="djjAlx3w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D3EE206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726445AbeLNFLS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 00:11:18 -0500
Received: from mail-ot1-f42.google.com ([209.85.210.42]:46980 "EHLO
        mail-ot1-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726437AbeLNFLS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2018 00:11:18 -0500
Received: by mail-ot1-f42.google.com with SMTP id w25so4255481otm.13
        for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2018 21:11:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HlpGsuza5i6S4la2WOP+Zx/XH6BJtfP5My0DzolvmTQ=;
        b=djjAlx3wRshV5aDTHERXyad68nEqt24jE5o590pVTeIdgb/o0MDmJ1ZMNB+66man/2
         ZDIbRZSSCnQaDJBkQ9ZEqTbK10rgW/qtoTdTMy4UGerAyqLG9kCpkjbRzLDBRe+Gc0YA
         EtXvP3RwcOmF64qmcGczfxCJ2QEwWDEaSifilZTvHao4He9ef51G4Barm4G0TCh13rJ1
         zJ+3DIUBx207Qq85NjmBex0GWhIXrYFfX4ovSsPg4tC/Un8wcyfu4SSizZ5P+e7TqTiD
         juIrR381h0b3wQ43+GIbr2Y0zWnzT0QmURazFgfT9hfv/MlIMpk6rixXYKvZ2HIZfHVA
         Pq6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HlpGsuza5i6S4la2WOP+Zx/XH6BJtfP5My0DzolvmTQ=;
        b=hZy2s392xjZJm42RX/ynoiTFLi0SoA+ZOf0SS5WcWwXUKgx6WaLaPThdBoz6iap4OJ
         hjR4z3SFnSxejMXCtyF6eSlssx2Hv2fdosApkjGhkxaI40aLZrf2F0uHd3TnBN+SaI4S
         BE5rDByrh6PzoORM9wbmvnXN6uGSMOfOkU8BKZ3WXHxvYDVudj0+q6/mui0LhLTI/h1Z
         sm8f5rYV6DsAMEJzzpEPn0LxPV4h4l2kpVQaYWjCLLOdgoRlKLuCUqVpMyWxynzkzwTk
         u+pGpksimdlp5Dnz7WDKVmhJnqoRnaJhU524x0xurkUKwynk8pFMAWUOKZYPZv6TIhXj
         Qmeg==
X-Gm-Message-State: AA+aEWZKIPTPbja7/vgtME95SHmXj1bTIouuiRW2+jg+t/B7/03UTqid
        lLvrr5sWwrgORde8nanNP3OdpiKBTMhM4kLf5gxooQ==
X-Google-Smtp-Source: AFSGD/UC31ZhITuJwiJZZ4INFsSAxlm/vEbBXo9MshkZpzL/We2xVoyLze7viI8YdnEs1Z4Sdp4iO/a0F2YuPZmyB9s=
X-Received: by 2002:a9d:3f34:: with SMTP id m49mr1078506otc.23.1544764277286;
 Thu, 13 Dec 2018 21:11:17 -0800 (PST)
MIME-Version: 1.0
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
 <09842ee0-9948-a5bd-a155-e0d6552b23bb@redhat.com>
In-Reply-To: <09842ee0-9948-a5bd-a155-e0d6552b23bb@redhat.com>
From:   Ashish Sangwan <ashishsangwan2@gmail.com>
Date:   Fri, 14 Dec 2018 10:41:05 +0530
Message-ID: <CAOiN93kfW2H_OEfUGxC4UKJPvn8Lo5Bpkf77UKcxHwWsBwEhXg@mail.gmail.com>
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
To:     ffilz@redhat.com
Cc:     linux-nfs@vger.kernel.org, neilb@suse.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 13, 2018 at 9:56 PM Frank Filz <ffilz@redhat.com> wrote:
>
> On 12/12/18 10:57 AM, Ashish Sangwan wrote:
> > Hi,
> >
> > Our NFS filer can sometimes return same inode number for different directories.
> > For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
> > and dir4 might end up returning the same inode number to the client.
> > Though it can never happen that inode numbers will be same for two
> > directories and also there parent is same. Can linux client handle
> > this case? What issues it can cause?
> > https://lkml.org/lkml/2006/10/2/346
> > I stumbled upon this thread where it is written that nfs client can
> > handle this but userspace will see inode collisions. Given that this
> > will happen only for directories, userspace utils logic might not get
> > affected from this as hardlinks on directories are not possible. But
> > the thread is really old. Wanted to confirm if this holds true even
> > now.
> >
> > Thanks,
> > Ashish
>
> The find tool will detect the collisions and report them, and if I
> recall it stops proceeding down the directory tree from the duplicate
> inode number. I know for sure I've seen it complain, and pretty sure I
> saw it stop descending the tree into the directory with the duplicate
> inode number.
>

True. Was just looking into the find code to check how they detect cycles.
They are using pair of "device node : inode number" so find will
certainly complain.

>
> Frank
>
