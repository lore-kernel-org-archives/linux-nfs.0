Return-Path: <SRS0=2uGU=6P=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26720C4724C
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 18:21:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 00BAE216FD
	for <linux-nfs@archiver.kernel.org>; Fri,  1 May 2020 18:21:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1588357319;
	bh=Um7RoGUIHgQ8GZBTGxBQtb71GMGyRZ5tADvfvjI5JZQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=bXyyNUJLGVePC9PffQB6IzAgWY1iIsztbbreqkzgb6b9mTkOE0h1nM+AxoRqDqbiN
	 y864ExYmrVR781Q53y6eCi9+tp37WH+qkQzEPy7TPFroDwtWL0sUy9T4OA9YAHSV45
	 RZx2UFhcalX1tH1RYcGI4UYEfsa4DxE/I1hKGKsM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730026AbgEASV6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 May 2020 14:21:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40266 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1729599AbgEASV5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2020 14:21:57 -0400
Received: from mail-qk1-x743.google.com (mail-qk1-x743.google.com [IPv6:2607:f8b0:4864:20::743])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A5E08C061A0C;
        Fri,  1 May 2020 11:21:57 -0700 (PDT)
Received: by mail-qk1-x743.google.com with SMTP id l78so10075217qke.7;
        Fri, 01 May 2020 11:21:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=KiYd6hVsmrnt0vWm34SLnLpgGlMhVF862REnMZFBaRo=;
        b=gn94t0znEkJj8IzRShTGjgN6+qdPrjiLurgsaTfax0JU9ifHIxoDcu0vsJhsZSyoKA
         4zKbH0y7TJn3Defs77/2hgzXXqx0rUP3IYBZPYzXGN9jB6bBpEQ55fbEWogJuGTENxpP
         LrEqERrEPea7wnM0W6mtsXbsulbNJq5kPqqheRLOOhZ2PUyPm7UBHGNttFHYLWIbPluF
         G5bVeX5o/IeZVGDfc8iaSVMzFFfZwbLZjgT/Jk64vsO5NG0QOY0gbc1lVrmg2KDARZqG
         /6wIGR5Qga7AzLsjKap9/K9tHa0ud06hNYmMXXHEmxDwtVIevikLnnDexnfn32VzIIv0
         Ul9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to;
        bh=KiYd6hVsmrnt0vWm34SLnLpgGlMhVF862REnMZFBaRo=;
        b=LdUUajCXLsLWUtj3offLbyIzVK5rOgN8OR0A10oNMijg7Wncq0T7BQIf1lRp8DfHGH
         HT4N5HRkIeVOu7iM/e3VC6fgSxn6pslbG71oa/xINBearEMstWzG8FKqwXVZ5/FDcasZ
         bLbmu1SystX3KQB3nrd7REdZ6lbBCd/JPJ/417YywCuewcbAeWLfCrv0gWZNw37PXcUf
         iWPUxSOEvotgLU5YiV2+Bib59nGYDZBz3s2VzA5QGZUeqBAFmROiUHtI1PSMi4XyIkEM
         mDKN2j392wSlZxpu2TKOQO7PZcxkpuYvghSsqUH2RVMxYhHtsE6rc3kohKvPF+31t8UB
         T5xw==
X-Gm-Message-State: AGi0PuY97TXqACcP7OaTcvqCI04wBSO3IiIw2Sk8DdIhPb6rn+v5J46B
        5UjxoBvrXZN8JSSJirq7iPY=
X-Google-Smtp-Source: APiQypK3gqYshcrDQKI0pZ8y57MCQ65ILdE0a3EDJg6ikVyB2Cdtx/qrnZep5+DsFZXjxC29bJ0T2Q==
X-Received: by 2002:a37:a049:: with SMTP id j70mr4711692qke.193.1588357316620;
        Fri, 01 May 2020 11:21:56 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::1:e6fd])
        by smtp.gmail.com with ESMTPSA id c23sm3130133qka.12.2020.05.01.11.21.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 01 May 2020 11:21:55 -0700 (PDT)
Date:   Fri, 1 May 2020 14:21:54 -0400
From:   Tejun Heo <tj@kernel.org>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, Shaohua Li <shli@fb.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] allow multiple kthreadd's
Message-ID: <20200501182154.GG5462@mtj.thefacebook.com>
References: <1588348912-24781-1-git-send-email-bfields@redhat.com>
 <CAHk-=wiGhZ_5xCRyUN+yMFdneKMQ-S8fBvdBp8o-JWPV4v+nVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wiGhZ_5xCRyUN+yMFdneKMQ-S8fBvdBp8o-JWPV4v+nVw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

On Fri, May 01, 2020 at 10:59:24AM -0700, Linus Torvalds wrote:
> Which kind of makes me want to point a finger at Tejun. But it's been
> mostly PeterZ touching this file lately..

Looks fine to me too. I don't quite understand the usecase tho. It looks
like all it's being used for is to tag some kthreads as belonging to the
same group. Can't that be done with kthread_data()?

Thanks.

-- 
tejun
