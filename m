Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 058F3ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:25:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BC3F207DD
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="NOS/avSw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BC3F207DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727856AbeJ0FDs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 01:03:48 -0400
Received: from mail-lj1-f194.google.com ([209.85.208.194]:36107 "EHLO
        mail-lj1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727842AbeJ0FDs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 01:03:48 -0400
Received: by mail-lj1-f194.google.com with SMTP id s15-v6so2324134lji.3
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 13:25:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GOiijbCg+uXy2wIwP3kyk+BVBIFGQNq9w47q/SOLiyc=;
        b=NOS/avSw16pVK1Tf2rGyKBIiZxHdE7DAhh8KjAkMSXL3JEZWRYsDZXMJIsb2JwqKkQ
         0fdt7LP8heIavDEIRJapfFUWZ1floUH3NdMA1dEW/L3VQ9cklrc8LUUZS+2a/aRmP5DP
         eq24E2yr1HHfmuqcaTbti0J3IE5wFIdkh7Vv0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=GOiijbCg+uXy2wIwP3kyk+BVBIFGQNq9w47q/SOLiyc=;
        b=pISksvn1re6Hw56Lzi9JOlNEhYJOeAFlrcUf09P4ml7FTgEV2hyQHe/5zH5Aq6pPvH
         HjzP4jWfiYHd/cdwyxXBwpcDI40fu7/TqYGwOq6mWLO3WXDqjX/9kFs6AJq9pLNrxloU
         epnCVjW9O7yDxRzyjpmRLthvtk0ktR2vEiPfE8zclf37jTi3xSuZdK2jTIfiU2/GNWLk
         1G6ophI0yigwYVuXEtht4UTzAb9WbCO1Qc3YcoyFGmuHKWJa5gLJ27T1Z8ovKZyCXRPH
         yrXgP40ApCAz6QemYBWLEbBr5MVY8RDUSLGetra3a0mQClSs0id1+7BmNuLWGkPWCKke
         XrVA==
X-Gm-Message-State: AGRZ1gIdJHB5NgkkIdm9b7Afg6rovunhqPBC8bvfSLleHP4bNkZWvQgq
        AJ1jxy7iS+vnvdeo9dgNXI0xT2RpXtNQGw==
X-Google-Smtp-Source: AJdET5ej3qBcFi05/SLRxSOmoGiV4c7Jsjsamyk67oJ9jLKFwZid6OWS3/rahP/jnXhgocplOQX7fQ==
X-Received: by 2002:a2e:458b:: with SMTP id s133-v6mr3658456lja.60.1540585520485;
        Fri, 26 Oct 2018 13:25:20 -0700 (PDT)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id q78-v6sm1512210lfi.44.2018.10.26.13.25.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 13:25:19 -0700 (PDT)
Received: by mail-lf1-f41.google.com with SMTP id d7-v6so1865960lfi.2
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 13:25:19 -0700 (PDT)
X-Received: by 2002:a19:288c:: with SMTP id o134-v6mr3276283lfo.124.1540585519180;
 Fri, 26 Oct 2018 13:25:19 -0700 (PDT)
MIME-Version: 1.0
References: <6bbed95d83465dde644c6f66acc73e3cd94f123e.camel@hammerspace.com>
 <CAHk-=wheW3hFQ8Jy5YYnNL1V+ZqA_qQoA63q2uK9ngz4=pXCqw@mail.gmail.com> <bafa9f6ca7da84e710bc9e1af8fa7428a8331bb6.camel@hammerspace.com>
In-Reply-To: <bafa9f6ca7da84e710bc9e1af8fa7428a8331bb6.camel@hammerspace.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Fri, 26 Oct 2018 13:25:03 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi9j8SzN3nvVaCU=5c4J=Z3Xom0W59DhBRAR+YbY+wQXQ@mail.gmail.com>
Message-ID: <CAHk-=wi9j8SzN3nvVaCU=5c4J=Z3Xom0W59DhBRAR+YbY+wQXQ@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.20.
To:     trondmy@hammerspace.com
Cc:     Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 1:21 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> We agreed about a year or so ago to take turns maintaining the linux-
> next branches.

Heh. That was a simpler pattern than I thought. It was just hidden by
the fact that there are sometimes more than one pull request during
the merge window, and then a variable number of "fixes" pull requests
during the rc's..

But now that you mention it I can see that yeah, it just alternates by
releases..

                   Linus
