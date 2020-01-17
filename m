Return-Path: <SRS0=zz3K=3G=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6A01C33CB1
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jan 2020 14:36:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FB172072B
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jan 2020 14:36:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579271793;
	bh=T+tM8XLKiveDCjG2afrekTDa7DvT12FJcZuWsK9nIS8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=GhFtgNGMQOwAGwKBMlR3cvUDgR5RXNj1+vx6ZLOHyuHqAJ363BxXgJRzsNANnlEpw
	 IgsXH/4bxZ8QeAHIcherFxrxOUbBdbQ2fVO0q/odSKnEX6dHfoa6lkEnoc5c/DsfX8
	 FILlZ5qwxu7GkGis9r6eQ0SEOEftfnuZpAgAyXQg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726974AbgAQOgd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Jan 2020 09:36:33 -0500
Received: from mail-ed1-f41.google.com ([209.85.208.41]:38010 "EHLO
        mail-ed1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726942AbgAQOgd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2020 09:36:33 -0500
Received: by mail-ed1-f41.google.com with SMTP id i16so22446722edr.5;
        Fri, 17 Jan 2020 06:36:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=H4aYYP5AqFJ3Bp+q4OGVka8zI0UJFy5rbCnPHZ0rHek=;
        b=SOk7gZypapa5fJcaGJwMWB9MkSwEn3xhy3XG8XagUdWDSXt9WLNyIQEkCPGh53rwy6
         i47bOsVvLssc660dIBAEbAvXvYKtBJYvFQ1m2wvxm79TY2WYCwoHsXvpNJCosUa8TEgR
         C3Z0F+UG+ymEmwiP1xIBIv+6Hapyj4EmVsamLO7RQqU01buSuLqrt8HuZcd8zIM0qEiQ
         HjyGXBEWGQUxvdMdv+5tiI9YUmMppZpUYWmrL4kTvNGdabiC5jIhA9Qqu1t05q4SjE2E
         p59NHnnqFH2VRXSl4cudW2IX1bADS4V1hmQz6FTyIWBQWt4zspkNYtL00cVclW61FW3b
         UtAw==
X-Gm-Message-State: APjAAAWv3266GEXzwak7k8ONA4ijNQWUnFqGoDrHRFYFgp3RKoX4tduk
        tlNksFztNxcFJKxt479fQ8o=
X-Google-Smtp-Source: APXvYqylfmjgftirP/3R0/bK+q/MT/hT7xjBH4da12u3eRqY+0MPaSabIAFYhwsLRMUWoEM45fNrJg==
X-Received: by 2002:aa7:c591:: with SMTP id g17mr4142644edq.341.1579271791174;
        Fri, 17 Jan 2020 06:36:31 -0800 (PST)
Received: from pi3 ([194.230.155.229])
        by smtp.googlemail.com with ESMTPSA id p24sm978321eds.17.2020.01.17.06.36.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Jan 2020 06:36:30 -0800 (PST)
Date:   Fri, 17 Jan 2020 15:36:28 +0100
From:   Krzysztof Kozlowski <krzk@kernel.org>
To:     David Howells <dhowells@redhat.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Scott Mayhew <smayhew@redhat.com>,
        Arnd Bergmann <arnd@arndb.de>
Subject: Re: [BISECT BUG] NFS v4 root not working after 6d972518b821 ("NFS:
 Add fs_context support.")
Message-ID: <20200117143628.GA3215@pi3>
References: <20200117131649.GA12406@pi3>
 <CAJKOXPeCVwZfBsCVbc9RQUGi0UfWQw0uFamPiQasiO8fSthFsQ@mail.gmail.com>
 <365390.1579265674@warthog.procyon.org.uk>
 <432921.1579270135@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <432921.1579270135@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 17, 2020 at 02:08:55PM +0000, David Howells wrote:
> Can you do:
> 
> 	grep NFS .config
> 
> for your kernel config?

It is a regular exynos_defconfig from the same tree (so linux-next).

Best regards,
Krzysztof

