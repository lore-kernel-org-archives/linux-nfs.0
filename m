Return-Path: <SRS0=L+CW=7D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7459C433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 06:28:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A047420748
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 06:28:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dropbear-xyz.20150623.gappssmtp.com header.i=@dropbear-xyz.20150623.gappssmtp.com header.b="slNA0LMV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728218AbgEUG26 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 May 2020 02:28:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36658 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728172AbgEUG25 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 May 2020 02:28:57 -0400
Received: from mail-qv1-xf2d.google.com (mail-qv1-xf2d.google.com [IPv6:2607:f8b0:4864:20::f2d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 60D0EC061A0E
        for <linux-nfs@vger.kernel.org>; Wed, 20 May 2020 23:28:56 -0700 (PDT)
Received: by mail-qv1-xf2d.google.com with SMTP id p4so2587099qvr.10
        for <linux-nfs@vger.kernel.org>; Wed, 20 May 2020 23:28:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dropbear-xyz.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XcQ706mnkEUUcBhpxWy4uMZE46OzXR5MKbNg5tOP08M=;
        b=slNA0LMVAH2uhsQP/DitPkZcZcs6y2T94XBE5xB4eOjuTKqBVtEvgxTfKLutP7h1jx
         xvPuVuKrAPtoRR/3s2qC9s5dcZn2Ty+lQn5/rre1f33Tbs/DT6ZbD7GlgdIQLPeGtY99
         2J52amdnIZYeTNeqUTyuJbGix4g+AZPVIrh/d16iL9fzsGMSvy4IDlsFI/jdXEMf6lyK
         qH2ba6N52boFXUkGBgVMYa8GcFQWjVAmvzvQile2FK5886nYKKyRoxu6pIq539KxDnwv
         RadnSlXdzsQ9CjV2ZbgqeObhrgnk5Ia8GNK4F0kE9/QEhSs6wOsXJVTBlPdj+h6y10ND
         9lyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=XcQ706mnkEUUcBhpxWy4uMZE46OzXR5MKbNg5tOP08M=;
        b=Mf372mBZZrlemXQIqJO81FO4KeONjcXuM/K/6qk977D6DN0+LLq4h1kpnjJA62rzOh
         /TMWGEjdx7Xjl7ulE10Yttldp4T7dVEEfaSaJ4nyQZdHtg7zrfgnQXiINa0nX44O3dkW
         1qePvKP/Z9CIOSnt68AbmYIY5as3H18mWF2LZktSB+7+jfHbp3b22xXByH65pdpMD0qH
         IeGCKmyNLq7SAyJqfmVokCA14k6n5vTPTwNhX58ne4OYJlXyv0GjK1V756Hs262gCxKT
         eyM7RAxTeJPaVosj82s3VYUmem3Um3Vlug05R5xb6O/fN0VrLov0VXcM9y8XVM8u1qIj
         WC/A==
X-Gm-Message-State: AOAM530jbNDBzK/HvQBBuG9fW2pScUDJtu3Jk0VmzB3apeAER0o7c1l4
        uM5vyFJl7fsfuR4zLgJHaA9a4HqU3Ps9Ud+zu/cePZJB
X-Google-Smtp-Source: ABdhPJw6tB8DyPWfRUV1IT5oyd00LeUvUo1qjMTiw14xaGRpJu3Fiyg26kBvhwpO3sl2Q5Th6ycWcJ2KA+WCxuCck0k=
X-Received: by 2002:ad4:4d03:: with SMTP id l3mr8769799qvl.158.1590042535217;
 Wed, 20 May 2020 23:28:55 -0700 (PDT)
MIME-Version: 1.0
References: <20200521023055.GA1246587@dropbear.xyz> <87eerdan1q.fsf@notabene.neil.brown.name>
In-Reply-To: <87eerdan1q.fsf@notabene.neil.brown.name>
From:   Craig Small <csmall@dropbear.xyz>
Date:   Thu, 21 May 2020 16:28:44 +1000
Message-ID: <CALy8Cw5xrcn94qRWb2rcn9FjcoYFY3_gZiO=ekvyYopR3zBhsw@mail.gmail.com>
Subject: Re: How to separate NFS mounts have same device ID
To:     NeilBrown <neilb@suse.de>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 21 May 2020 at 15:12, NeilBrown <neilb@suse.de> wrote:
> I would examine /proc/<PID>/fdinfo/3 and extract the 'mnt_id:' number,
> then look for that (as the first field) in /proc/<PID>/mountinfo.

The mountinfo looks very promising and a better way of uniquely
working out where a file is mounted. Thanks!

 - Craig
