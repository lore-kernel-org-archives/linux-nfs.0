Return-Path: <SRS0=xh2Q=UV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D12C48BE8
	for <linux-nfs@archiver.kernel.org>; Sat, 22 Jun 2019 20:23:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D03532084E
	for <linux-nfs@archiver.kernel.org>; Sat, 22 Jun 2019 20:23:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OOOVQJTX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726286AbfFVUXA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 22 Jun 2019 16:23:00 -0400
Received: from mail-pl1-f193.google.com ([209.85.214.193]:34445 "EHLO
        mail-pl1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726299AbfFVUW6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Jun 2019 16:22:58 -0400
Received: by mail-pl1-f193.google.com with SMTP id i2so4669224plt.1
        for <linux-nfs@vger.kernel.org>; Sat, 22 Jun 2019 13:22:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=1w4upBhO9u5DrCydQoLXXnUxv1WXapfYDD1jk9PIDQA=;
        b=OOOVQJTXjb56HyWy+ezfShBHwUM1Mo4Vj0K02GtwEpgbGBm89AXs7U9eg6dsqPNjZ1
         PMavEq93wzBvgfsZw6cViARLTasvbLlruNvNLvZhcdW4St16utw5n9h/UFVZn/WVjhGI
         DdXdmnN/RhV1S7FgweNpZFokXOl0F1RxYo5Mo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=1w4upBhO9u5DrCydQoLXXnUxv1WXapfYDD1jk9PIDQA=;
        b=DkzDJUFVtFH+k0kCX+coqtxnfOEb4OA01dpw2LELObNdYwrtc7RSwPWAp8ePUVOb52
         r9OuDow4BAeowFl9KXvgezkMMQpuu4zF8BIfecs/tCJKyvTVW0MbIbVoG9/HyCDLJSuN
         3QqPl9pR5PhAVWoyrcqR9Qathakew3GPsaAZLffWGYNDLTzJHM2k95D3E53eTguZPccw
         Gt77lzGQr8KNeWc9yuENLVEogrpL5s/ZSpu1G9wxsxLH04MeB5qz21CCEqIVpIr/SXBY
         XvbtMgl++iCHuNEV2lahme9uhGMYaxyGw51omqL5W5xop5PFvO1Q8ZxM3MYVk2vqAvUb
         0aQw==
X-Gm-Message-State: APjAAAWSeI0dl/SIJyDjX7fdkznjVB4NoZkfHEApB7faOqlRT7Bz5UqM
        fKUnE+9vfHNZost5/r9ytEt2uPCMU0I=
X-Google-Smtp-Source: APXvYqwPSy1JJwzKBw7YFhSjIjET++vlOZO2iqmz6J9vOjD7VZoKy8n6adF2zxwhH17r5CEaW+Y5Mg==
X-Received: by 2002:a17:902:7894:: with SMTP id q20mr127674761pll.339.1561234977830;
        Sat, 22 Jun 2019 13:22:57 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id m8sm5325462pjs.22.2019.06.22.13.22.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 22 Jun 2019 13:22:57 -0700 (PDT)
Date:   Sat, 22 Jun 2019 13:22:56 -0700
From:   Kees Cook <keescook@chromium.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 08/16] nfsd: escape high characters in binary data
Message-ID: <201906221320.5BFC134713@keescook>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
 <1561042275-12723-9-git-send-email-bfields@redhat.com>
 <20190621174544.GC25590@fieldses.org>
 <201906211431.E6552108@keescook>
 <20190622190058.GD5343@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190622190058.GD5343@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Jun 22, 2019 at 03:00:58PM -0400, J. Bruce Fields wrote:
> The logic around ESCAPE_NP and the "only" string is really confusing.  I
> started assuming I could just add an ESCAPE_NONASCII flag and stick "
> and \ into the "only" string, but it doesn't work that way.

Yeah, if ESCAPE_NP isn't specified, the "only" characters are passed
through. It'd be nice to have an "add" or a clearer way to do actual
ctype subsets, etc. If there isn't an obviously clear way to refactor
it, just skip it for now and I'm happy to ack your original patch. :)


-- 
Kees Cook
