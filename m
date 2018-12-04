Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B24FBC04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 23:34:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 748D32082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 23:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F4un3MxT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 748D32082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726396AbeLDXen (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 18:34:43 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:42411 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725875AbeLDXen (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 18:34:43 -0500
Received: by mail-vs1-f68.google.com with SMTP id b74so10950270vsd.9;
        Tue, 04 Dec 2018 15:34:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RRZR8ckwo5dCR218TXcSn7H99CQoqpHXU2b37uy3Fr0=;
        b=F4un3MxTsqQYR45tlWip/2F+UXu7+S4Wwn5QNtEp4ot2nKGKMoxXJjKaFHb/ZpO4V+
         irFUNzOdICWcTYxTeSL2QKw6NOOAiOcwuTp4du2apRLXH0Ttynx6+v1rw4LgEb6B7cFT
         WhCZ/o99gXlx1c/f+M4Tkly5D9sUuI6Yl+s4cVzhJoFKXniMZxfN9Ory4qLOD+stpWI1
         mUcJf9QiGjNrCVNxcSZWtAs4XLIi9tgXRohuN6fMhRWEnLPwsLsLG81QqZxt2PoFpZjt
         2vQOJDJIP4/HHeKAKna62YxhVUaf7590oJDRLCdxC+aZOUVpxzCarK3w69CtW1n9QEkJ
         BRCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RRZR8ckwo5dCR218TXcSn7H99CQoqpHXU2b37uy3Fr0=;
        b=HZheKnHAZHjlrBduM4Y6KHnKyg1Ebv+vCYio6x+sgjzIA3OVlse0Rc+5GmpO9+Gsp4
         QaUJdrvzCdGWzqPGWGGKevLQkK4Yg9n53FmDHLROoXbHmRiVsKELcBdwIr58o5Odg/Zk
         37mhzzE0tFSGsnNH269K+6YTbPzU/gl8uXqKMP4Lsgv9sOzcbHRLMDNBhGn7QQfGyWSW
         QqelU0/cwbYqjd7ms3h6IiBlAhkt4FhU/aSR/fJP5ehTHr67vHfWohrEEE5xNcXSP+5S
         AVJlBllK4a5GQV83501e8lsq/4n/z3M2UYWYwxFjNxClC4fhiZsDQ1wQ+jMpn59ZlTIw
         4OAA==
X-Gm-Message-State: AA+aEWa5XZvnN9a4cIzzum/C3YfiFZeKc8HjPXG4nP0Fg0e9u1tJeYTH
        QfVpSkma4ot4C8pNHGTGksXH/6dmHmItp9tFgTJhPQ==
X-Google-Smtp-Source: AFSGD/WpEyAiE6hHQyPWzQmMpJjWHOh6S1h2zMOB6IsFveExbMLtYyPtGemULs304ILs84wQFI+v/38xRmwT7VOKZ4M=
X-Received: by 2002:a67:ca9d:: with SMTP id a29mr9801583vsl.194.1543966481229;
 Tue, 04 Dec 2018 15:34:41 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-10-david@fromorbit.com>
 <20181204154347.GA6925@infradead.org> <20181204221847.GQ6311@dastard>
In-Reply-To: <20181204221847.GQ6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 4 Dec 2018 18:33:42 -0500
Message-ID: <CAN-5tyG7avm_qiZxzmHYjRL_OYN1meLv-SPmDYUX6vAdGBkc-Q@mail.gmail.com>
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
To:     david@fromorbit.com
Cc:     Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 4, 2018 at 5:18 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Dec 04, 2018 at 07:43:47AM -0800, Christoph Hellwig wrote:
> > Well, this isn't bugfixes anymore, but adding new features..
>
> I made that perfectly clear in the cover description. I called it
> twice, one of them explicitly stating that this series made these
> infrastructure changes because we have pending functionality that
> dependents on cross-device copies being supported in a sane manner.
>
> I'll drop it if you want, but then I'll just have to come back after
> all the NFS code is merged and do yet more cleanup work.

This doesn't needs to be fixed in this patch series. I think Anna was
pointing out to me for something to take a look at.

>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
