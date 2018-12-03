Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F39C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:54:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A1B0720834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uiY2VEPA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1B0720834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726526AbeLCMzj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:55:39 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:45861 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726369AbeLCMzj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:55:39 -0500
Received: by mail-yw1-f67.google.com with SMTP id d190so5303993ywd.12;
        Mon, 03 Dec 2018 04:54:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FnIps5GPhVXk/xj3XVQUvp3mrILlW8tnTGINm1NA+T8=;
        b=uiY2VEPA9M6JY2yqUW+YZfwCKHLLmRQNCgilfFlC9K5NWz4HFuf2S28kN/QTq710Kr
         jOtoLtnv7tKmPyU+tmGsdRcXinXh78Z7KK+h8LTqZN7TYbQxSJsDSRLqLfXzNOuQnBcC
         cvrttzDftP0ZegQk5OfEXGe7Dba2w4DW/XXnAh6L4NJBMvWTAE1wynakRfRCIxyst35m
         Vso4+pf8fdWER12Hr5M6Y6jR4LVcn46gWJtsNfwsT6Ben9b7Kta+K/kUMepcV9BpY1+A
         7OCgF/uVEdufr1v1m+NauzV/ViIdYqMQ18FL3zZW9y1VsBSFYbk1nk0wIK9OqupmazdD
         VNTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FnIps5GPhVXk/xj3XVQUvp3mrILlW8tnTGINm1NA+T8=;
        b=LbC/EuuvWpwC+w+W257I51LHdYrmx5a0jKLusGlgHrBdta0FDxDkIMcdJLKLzEDN8M
         mbD5dpbMwNVCfUXcBJx9/vjuY/hiC2GW4bFnMH4iFXu3pXamhLODGkLUK0TzbHFPcHCe
         +9tO5qk99/QRFx5gLSGNkS92U9ta93AZ53cDhQkDnOst1XcB9PCOJYbuz7Xg3p/+S89T
         lZMBye/qDQOL9a1I5Oh93ukk823suBr5/t30u9G1v7n+LIEE5HSOUslZkD4rgDL3Eyto
         HH4Hktii2HEP14kJkaBC/50W0xGi+cGwrBqJ0k03w/hBvmucpdhyGOxTIyqPJnmj+4gd
         OMYQ==
X-Gm-Message-State: AA+aEWZ3wsSSPyb7v5V3BACDLAUlaW7R+WiSa2PRz/gsMG0oP9SFXHYt
        17QgTWrjvi+wRkBS95oB3AuS5MNoiCJhExmnkG4HY7FK
X-Google-Smtp-Source: AFSGD/XdcnrKxDblCeeKjjtahA8YYagYc+yLRPa6JXF7KF7GrLarN7r8Jx9vqsdietYMdGJXGqIx3+9Z1WFnRBJSFWc=
X-Received: by 2002:a81:c144:: with SMTP id e4mr15969546ywl.409.1543841682688;
 Mon, 03 Dec 2018 04:54:42 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-11-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-11-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:54:31 +0200
Message-ID: <CAOQ4uxhsVfqGkYi1v1Gd6BnzGsCb5=sOcByB0Nwp_ZGaFTmOPw@mail.gmail.com>
Subject: Re: [PATCH 10/11] vfs: allow generic_copy_file_range to copy across devices
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> do_splice_direct() can copy across superblocks without problems.
> Remove the same superblock restriction on this fallback code.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.
