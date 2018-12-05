Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6EA0C04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 20:30:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 97DBB20989
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 20:30:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fNRrVgMZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97DBB20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727592AbeLEUaF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 15:30:05 -0500
Received: from mail-io1-f48.google.com ([209.85.166.48]:37410 "EHLO
        mail-io1-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeLEUaF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 15:30:05 -0500
Received: by mail-io1-f48.google.com with SMTP id f14so12336606iol.4
        for <linux-nfs@vger.kernel.org>; Wed, 05 Dec 2018 12:30:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=BWnfzKDjF3OtWMrmPALK1kJaoQ+tTY4ATySEmN1cFGQ=;
        b=fNRrVgMZA11ZNq08KWLK+HVX7DbYSmsBtrPdERH1LJQSj8Z2aEvBeIfS5KCQHumLvM
         91lsigXcCd43h9t1GYaw4qtUsCdRYe37E/Vlr1jF6ApdjUlT/LzAJQWaXsD62QAbgAnX
         18vnjx4MzQQ6asdwjAYbsxL2sxsqUdHy6KZ+MJzy5iPfbLzlF14TjzMFz2R5rXXXovP8
         f+vZ3m5m0jA7qmNkltzc79RYLsW+dYsmrXC4az9KS5H55TmJFu1F2F5+5JBCx5h2UJ+x
         PWJAPK4fZdXOWACQ9b2vN7/NJ8UEiX+aGZhbdOc1G2lYiSoMbjVFnkHz7+Tt0dYvtTqF
         931g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=BWnfzKDjF3OtWMrmPALK1kJaoQ+tTY4ATySEmN1cFGQ=;
        b=CqGIJcaAny1zCE8raij3FdaJfHv4pnhqYcMNk5PZTu1d0UvvsfJYtlNp+jV9HRpifE
         Q5apZesiTIHydEujMG9Um2CcpIlAoVkYWbfryTS6BAcFEpYNmfLM8VOmbKynJzboGcRV
         BWCHEexA3btrFCUCx8a1L5sBDDVcVtRhOqScr96suj7BeCMEkFJ6lfj5I1Q8E3jwEGtl
         99wTie9RAOSR64X0Ex2oMIYy32vi6eTs8Ldgv443dJQuI7Q+iF/gy/fiUv3e7NSWG6z9
         XSLIxfGgQRTHHchYXHVyGzYu0WZ4i1LTdPGpRM9m+Wd/U2mqSDAvnssGODJHmoYsPjBu
         tiAw==
X-Gm-Message-State: AA+aEWY5JyGE2U0aMq2zOfAUgDL27vEzGiucVAafTGMqaXLqPWCnmanY
        RQAfQd/6NBgWf1TPxGGQ1WM=
X-Google-Smtp-Source: AFSGD/WTT64KCiRyNYa1oUnQwL1WHT7axU2uvcD91p5FYtUhRFSvTtGQ40szKVGH+sqTEiCqi6UtaQ==
X-Received: by 2002:a6b:9156:: with SMTP id t83mr21771230iod.248.1544041804276;
        Wed, 05 Dec 2018 12:30:04 -0800 (PST)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id b140sm10238452itc.4.2018.12.05.12.30.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 12:30:03 -0800 (PST)
Message-ID: <0c94d447b8c8901a1d7c5fa4cffcf5d7b3960e86.camel@gmail.com>
Subject: Re: NFS client behavior on WRITE_DELEGATION
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Anna Schumaker <schumakeranna@gmail.com>,
        Soumya Koduri <skoduri@redhat.com>
Cc:     linux-nfs@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>
Date:   Wed, 05 Dec 2018 15:30:02 -0500
In-Reply-To: <CAFX2JfmYMnKoiQ0Kjt8SGLx2H=3GwwtLHco0wMR4xVHkJpLaoQ@mail.gmail.com>
References: <68c7c07a-949d-1ce0-ec7e-5ab71ffaaa3b@redhat.com>
         <CAFX2JfmYMnKoiQ0Kjt8SGLx2H=3GwwtLHco0wMR4xVHkJpLaoQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

(Resending due to accidentally using HTML instead of plain text)

On Wed, 2018-12-05 at 15:22 -0500, Anna Schumaker wrote:
> Hi Soumya,
> 
> What conditions are you seeing the writes?  It could be the kernel trying to
> flush out data to free up memory for other processes.
> 
> I don't think preemptively writing back data is necessarily a bad thing
> though, even with a write delegation.  If the server decides to recall the
> delegation, we wouldn't keep it waiting as long while we write back local
> data.  Additionally, if the client crashes then any updates might have already
> had a chance to sync to the server.
> 
> I hope this helps!
> Anna
> 
> On Mon, Dec 3, 2018 at 2:55 AM Soumya Koduri <skoduri@redhat.com> wrote:
> > Hi,
> > 
> > In our NFSv4.1 Delegations testing we observed that NFS client sends 
> > WRITE requests to the server even when granted WRITE_DELEGATION. I see 
> > that only OPEN/CLOSE and LOCK operations are served locally by the client.
> > 
> > Please confirm if this behavior is expected and if yes, can it be 
> > improved to avoid sending WRITEs to the server until the application 
> > does fsync.
> > 
> > Thanks,
> > Soumya

