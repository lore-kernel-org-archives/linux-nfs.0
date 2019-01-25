Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD36C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 05:50:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D710218D2
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 05:50:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WmVG7Xgn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726219AbfAYFuY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 00:50:24 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:38048 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726200AbfAYFuY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 00:50:24 -0500
Received: by mail-io1-f68.google.com with SMTP id l14so6849665ioj.5
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jan 2019 21:50:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=rhHv7oIg4j6cpyZ9UIrCUzuxErmm/SOKlmRW7lJfPoY=;
        b=WmVG7Xgn60XinJ/BWJgYuyIY0oTsguCN9TIPb9itYE3qNwARpAwcXA/6cArfr4TNNA
         gt70NMu7P4DGjYKTXhRnXMMzeOUlbDU8a1j+22wmsfj+3fc3DWysxYY/FX45u+wcplXN
         T47zcBiXwi2mZXLLjH43Jj6II73e63enBMDFFopm/lABezhQ5nyEEXFCuXY0lcOcZf4I
         hPzwqsmlKEGMxLDYTt6pTC8Ig4KCp7cKD2Zo+gVTC9Veqp4kX4qegUu1Up8xblqS1oQo
         KgFljCtUSrztHiy3i++DcG0iA5dIqEVEAz47kzxEXLTpy75732wsFIQ92LcHPVTrtrGa
         VgfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=rhHv7oIg4j6cpyZ9UIrCUzuxErmm/SOKlmRW7lJfPoY=;
        b=WmvQ1IFAOpBN6s/TtvrAgtZR3xAhBNim//Ky6wDZ4E4KzehQmL1xoSQiJjUNoyejz3
         +oykgnUG8DIB1YYOvB0Jk3os1yq+iduu5vu2Y6Fh/34VPWXG5R55XYyeUgoGJQpojQ7P
         3jgDuoaHBSLJGp5xmmQ0YXmjUhooNOll3GWVzxGBBh0bFEc94mKWFK7LjUDYT1juANbR
         8tLuNiGjwuHvs9lQnFuD4BWpC5BQuilHcZSR6QSDqOiV2rvzJnBaxuoAPtLRFjn3+lNy
         pg2ZU1QtqyafVRQVTic2dORezRWDT6orgA586DCVACp3b+Ufsa1jP+olrlbUYDlH9EP4
         J0xg==
X-Gm-Message-State: AHQUAuagl+uKV3Q93v99KchIggHLwqybBeKcAoZJBZH0hLmOA40HvAd/
        dw7jdo2NsfT0qashFTg7/A==
X-Google-Smtp-Source: AHgI3IaT0kY5EP+7FWPBseKZHHLLIqaGYWW/mOTOiEl/XDAJAVe0YM152/zGu0UzjzpbjHX4MrOk7w==
X-Received: by 2002:a5e:8306:: with SMTP id x6mr5100040iom.229.1548395422549;
        Thu, 24 Jan 2019 21:50:22 -0800 (PST)
Received: from leira (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id b22sm9856245ios.45.2019.01.24.21.50.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 Jan 2019 21:50:20 -0800 (PST)
Message-ID: <698446e18a6718ee1ced06ecfd06e2de802fa16e.camel@gmail.com>
Subject: Re: [PATCH] nfsd: Fix error return values for
 nfsd4_clone_file_range()
From:   Trond Myklebust <trondmy@gmail.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 00:50:09 -0500
In-Reply-To: <20190125004658.GB3953@fieldses.org>
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
         <20190125004658.GB3953@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2019-01-24 at 19:46 -0500, J. Bruce Fields wrote:
> On Mon, Jan 21, 2019 at 03:58:38PM -0500, Trond Myklebust wrote:
> > If the parameter 'count' is non-zero, nfsd4_clone_file_range() will
> > currently clobber all errors returned by vfs_clone_file_range() and
> > replace them with EINVAL.
> 
> Oops, thanks for the fix.  I'm still a little confused, though:
> 
> > Fixes: 42ec3d4c0218 ("vfs: make remap_file_range functions take
> > and...")
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > Cc: stable@vger.kernel.org # v4.20+
> > ---
> >  fs/nfsd/vfs.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 9824e32b2f23..7dc98e14655d 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -557,9 +557,11 @@ __be32 nfsd4_clone_file_range(struct file
> > *src, u64 src_pos, struct file *dst,
> >  	loff_t cloned;
> >  
> >  	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos,
> > count, 0);
> > +	if (cloned < 0)
> > +		return nfserrno(cloned);
> >  	if (count && cloned != count)
> > -		cloned = -EINVAL;
> > -	return nfserrno(cloned < 0 ? cloned : 0);
> > +		return nfserrno(-EINVAL);
> > +	return 0;
> 
> I still don't understand the cloned != count case.  I thought clone
> was
> supposed to be all-or-nothing and atomic, can it really return a
> short
> copy?  And how is that inval, shouldn't that be serverfault?

That, quite frankly, seems like more of a question for Darrick, not me.
I haven't changed that part of the code.

The main thing I care about is being able to correctly report
EOPNOTSUPP errors for the vast majority of filesystems that don't
support clone() or dedup().

Cheers
  Trond

