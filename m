Return-Path: <SRS0=33mF=TB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64818C43219
	for <linux-nfs@archiver.kernel.org>; Wed,  1 May 2019 17:00:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3109920835
	for <linux-nfs@archiver.kernel.org>; Wed,  1 May 2019 17:00:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c9cRJ1QZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726473AbfEARAX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 May 2019 13:00:23 -0400
Received: from mail-vs1-f54.google.com ([209.85.217.54]:37355 "EHLO
        mail-vs1-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726434AbfEARAX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 May 2019 13:00:23 -0400
Received: by mail-vs1-f54.google.com with SMTP id w13so10205151vsc.4
        for <linux-nfs@vger.kernel.org>; Wed, 01 May 2019 10:00:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fKeHm+YnMFQhnE5COYYd2wTHTYE5yGwHo3lDdnebjM4=;
        b=c9cRJ1QZQtCO0/mYbd0/5i4CUar4BNukWTS+G7jpwqDiNzZNV1I2edB+dOMbqXzfQN
         mhW68V4DfHLuHMdUGgFuw3BtCW6wAMRLTGARVl9g24jKKOObBPLzumTeE6Ku3J/zC/Rs
         3kKoRtXLz+OH40U9zaDIKNjnYtAm3sAsF9MfgJr3YB/1AReKlm/skRORZDQ9HVlkxL+f
         zJz1f4+jYMAYy/PU6bHdIuWRtCw1kB8ks9BemTUwcrrGzu34XCiyKAqYhPCuMUja77PS
         L1YKR17HUUy1neMNs0cNdR37rpUDpDaPudaVB9kgFJZXXZ1cWQBxdLvqV5CVr3BdlKhF
         liLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=fKeHm+YnMFQhnE5COYYd2wTHTYE5yGwHo3lDdnebjM4=;
        b=N/f3Y6Wh0XupAQ6BSaburuSVQMML84+VA5hTE5SSWaNl+QneRcuUMbiZkM7mWWacsv
         zPqjY/JhcKaDhWn1IzYUceDqckJynMHu7H5NjSKJnJYnNGlsVG+7tK4Tm82GX+9AZreD
         rZAcXqm0lg+tCZNe4LQ/NUgyZ5ncdBajuBgBVz0gcb2N6GqWvVL6fgd1zc+aZTzlsQIn
         IocaGFybnLg6yhFQLWXzrI0Z3HbJUwfTSbEtv1oZ/fKPohrIl8IZUIRBCgHjuIITmx1B
         l57MZ+Clzkk9LU0OfJZ4T8LYespLH7agkxk6WW2GQqaKI5Fa5zb5/ihuGJE1wfi09tWV
         B+Bg==
X-Gm-Message-State: APjAAAUQsIr0K8cCLLt1g+3jbj8XZhYIscC9xHZoiN+AhQPZAxerBRh0
        0w8TziOTmGgwray9hsz5Cbcbhm1C+w/M7kHWfnfB9w==
X-Google-Smtp-Source: APXvYqyUqlL9jpVL90DkvvlHC4IlULAcsEjfbXtupVrOhb+mGnoHYGwhZSQ0zSjaCUnEraTNpHXEENzrDsXLSmJMKA0=
X-Received: by 2002:a67:7444:: with SMTP id p65mr38135332vsc.104.1556730021507;
 Wed, 01 May 2019 10:00:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190501160636.30841-1-hch@lst.de>
In-Reply-To: <20190501160636.30841-1-hch@lst.de>
From:   Sami Tolvanen <samitolvanen@google.com>
Date:   Wed, 1 May 2019 10:00:10 -0700
Message-ID: <CABCJKudfkFB4QGp4J6E5r2Td+Wqw0dTYfMZkxVh9DgR7N=JwyA@mail.gmail.com>
Subject: Re: fix filler_t callback type mismatches
To:     Christoph Hellwig <hch@lst.de>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, May 1, 2019 at 9:07 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Casting mapping->a_ops->readpage to filler_t causes an indirect call
> type mismatch with Control-Flow Integrity checking. This change fixes
> the mismatch in read_cache_page_gfp and read_mapping_page by adding
> using a NULL filler argument as an indication to call ->readpage
> directly, and by passing the right parameter callbacks in nfs and jffs2.
>

Thanks, Christoph! This looks much cleaner.

I tested the patches on a kernel compiled with clang's -fsanitize=cfi
and the fixes look good to me. However, you missed one more type
mismatch in v9fs_vfs_readpages (fs/9p/vfs_addr.c). Could you please
add that one to the series too?

Sami
