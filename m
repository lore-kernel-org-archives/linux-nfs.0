Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8505C77B7A
	for <linux-nfs@archiver.kernel.org>; Wed, 24 May 2023 07:12:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239986AbjEXHMP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 May 2023 03:12:15 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48964 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239504AbjEXHLt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 May 2023 03:11:49 -0400
Received: from mail-ej1-x635.google.com (mail-ej1-x635.google.com [IPv6:2a00:1450:4864:20::635])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 400B010FE
        for <linux-nfs@vger.kernel.org>; Wed, 24 May 2023 00:09:25 -0700 (PDT)
Received: by mail-ej1-x635.google.com with SMTP id a640c23a62f3a-96fbc74fbf1so87347066b.1
        for <linux-nfs@vger.kernel.org>; Wed, 24 May 2023 00:09:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1684912157; x=1687504157;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=MB0PkgtOYu2DAciIYbJ/doyhq3ZdSDKw62DeZCSSPtg=;
        b=FYCG0I0xG/KCzcPeRgfWGhFKBLQH8yo4Mb+b3h/3/MNGJYaOJxYFefWYzCbWzDOLJ5
         GslHMTl4heaZuqXTEmqMZYV3JWjK8Zt4w+vYkPylVmw2imfly3Tp8dcGkm97OVZ15gac
         hO02Kope0eh3dNS3sBBKR4sYeiW7mzVKy2JdY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1684912157; x=1687504157;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=MB0PkgtOYu2DAciIYbJ/doyhq3ZdSDKw62DeZCSSPtg=;
        b=A7l1hskzm1S0jAyFCrEx6NR2cS3KNsD2MgOZoXkGSIdRbXY1nupKy7ODEadFK0aQic
         m3N00nIJE5BSSw2Vjp9H7FE6HukKI7PQG0HbOsRYhTIqGvJ4Zl3ul//r2VUW2OUrkOZE
         dQTWUEq1fnym60bU+srdApELgNUQ0q2ogqEWxbTDIIJ2YmBEUe7rQjaFYRtQPNU/mGIX
         XHRRrzPbHrm48I81m8aq/MScDmjViHdxYxSkZu/o5VarVQW3i2CnweR0GOVRrogU5ouJ
         yV8a/ykUHaE2Nfyr/X5Ff7TChbSfduGGNSLISNkCidNXavzGHU0smN3aC5507hwJtMXh
         n5eA==
X-Gm-Message-State: AC+VfDwYnfVOYOzYZ2i/NQrYeffX+FUYNsdhoBrcMgvYdg7+Oq0g1yO+
        U3DwosT749lFXpN4MX4BbwsL5GsMG7CauZqaRrrkJA==
X-Google-Smtp-Source: ACHHUZ4OvyrYEQkEUfZSmUZD5S0dixYDveppalH3smz8YjXbgWTLCqDqGb6U6n7MopqEkuxUiQE5XNBE/E81YW5lpSg=
X-Received: by 2002:a17:907:60cc:b0:96a:580e:bf0f with SMTP id
 hv12-20020a17090760cc00b0096a580ebf0fmr18686933ejc.14.1684912157630; Wed, 24
 May 2023 00:09:17 -0700 (PDT)
MIME-Version: 1.0
References: <20230524063810.1595778-1-hch@lst.de> <20230524063810.1595778-12-hch@lst.de>
In-Reply-To: <20230524063810.1595778-12-hch@lst.de>
From:   Miklos Szeredi <miklos@szeredi.hu>
Date:   Wed, 24 May 2023 09:09:06 +0200
Message-ID: <CAJfpegtt2eD4Cw11f12cmcvHLe9VHhPLQdJWpwyAmeY-SrVuOA@mail.gmail.com>
Subject: Re: [PATCH 11/11] fuse: drop redundant arguments to fuse_perform_write
To:     Christoph Hellwig <hch@lst.de>
Cc:     Matthew Wilcox <willy@infradead.org>, Jens Axboe <axboe@kernel.dk>,
        Xiubo Li <xiubli@redhat.com>,
        Ilya Dryomov <idryomov@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christian Brauner <brauner@kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
        Chao Yu <chao@kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        "Darrick J. Wong" <djwong@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>,
        Damien Le Moal <dlemoal@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-block@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-xfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 24 May 2023 at 08:38, Christoph Hellwig <hch@lst.de> wrote:
>
> pos is always equal to iocb->ki_pos, and mapping is always equal to
> iocb->ki_filp->f_mapping.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Damien Le Moal <dlemoal@kernel.org>

Acked-by: Miklos Szeredi <mszeredi@redhat.com>
