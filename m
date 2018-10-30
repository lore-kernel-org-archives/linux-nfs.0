Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1317C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:07:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 76D252080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:07:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="d72Byb2Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76D252080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727832AbeJaFCM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:02:12 -0400
Received: from mail-lf1-f66.google.com ([209.85.167.66]:46286 "EHLO
        mail-lf1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727650AbeJaFCM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:02:12 -0400
Received: by mail-lf1-f66.google.com with SMTP id o2-v6so9880712lfl.13
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 13:07:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YHlA1Gy9bikOKYy8gzOAw1wz0+eQluWCb2m298a9UsA=;
        b=d72Byb2QHgPqTgAXvhHNvfoMjdDL+qRXq8PyQsTUBX+BSh1aY+dF33CZzrYg8JSsSn
         /HZRfN5/n7oQ/Dg4G9zq20D61EXR1n9qOKtknZY+dxm6Wn7pHGrgtl2aohmKZF9AiuVE
         Fmy7UPs8GF+4fssy3XS+X2ixM640fNszugEqM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=YHlA1Gy9bikOKYy8gzOAw1wz0+eQluWCb2m298a9UsA=;
        b=C8uzPnO1aOiS/z5LuJ/m+pNVaSM1sBhAfRh52mHDE5r6VQcQMCZaU3fN4lDAPIOb3F
         MfdYeHY9J4iR5PchPOD123sk9mU/CBR0lV+EJcxat3sv2pAH6d1pwQlA1L5f3J/IWW4O
         CZ9GSWk8n/Sb3wRrHr7bEMUYa4NOMx3v4TRFRZ5hsCKS8x0LpVCDHuaPfPyErhA2VtQM
         /irr4aNovUIaKxs5iO3umlp2nvTAurVEdt4OeQ9EsBuGCf2Ngmj4XzRo7jfP9K/UyhzH
         ftrBq6Vs/4JtD7C/aMQOyABzpTn7rplPRlDdKuPZqLe0wP1Fk9n4rktn5EySH2bSTTrl
         xUMw==
X-Gm-Message-State: AGRZ1gI8w1uDGLIBMxnrq/5uikM1vhClXdi+y4KOPXgUUL8LzyLmbfE2
        AtlllnOdITdEXFvAwihxtrrFlMFgMHTx+g==
X-Google-Smtp-Source: AJdET5dT0TDbHMtXOe0guA0Yyk7HQlnWNQ2ZjlcMGCJlNPFmyRkTCvKeHEWzg2Ck+CJ0BiIjz4BEJg==
X-Received: by 2002:a19:6d0e:: with SMTP id i14-v6mr79021lfc.57.1540930035321;
        Tue, 30 Oct 2018 13:07:15 -0700 (PDT)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com. [209.85.167.46])
        by smtp.gmail.com with ESMTPSA id 2-v6sm3671323ljv.83.2018.10.30.13.07.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 13:07:14 -0700 (PDT)
Received: by mail-lf1-f46.google.com with SMTP id u18so9891273lff.10
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 13:07:14 -0700 (PDT)
X-Received: by 2002:a19:7019:: with SMTP id h25-v6mr68821lfc.147.1540930033935;
 Tue, 30 Oct 2018 13:07:13 -0700 (PDT)
MIME-Version: 1.0
References: <20181030191710.GA23042@fieldses.org> <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
In-Reply-To: <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue, 30 Oct 2018 13:06:58 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgeJzBWjCafB3nKP0QMJCyh3rAjN+s6Z+T+5hfAT81YMw@mail.gmail.com>
Message-ID: <CAHk-=wgeJzBWjCafB3nKP0QMJCyh3rAjN+s6Z+T+5hfAT81YMw@mail.gmail.com>
Subject: Re: [GIT PULL] nfsd changes for 4.20
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jlayton@redhat.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 12:55 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Pulled,

Oh, I take that back. Semantic conflict with locking name change
(recv_lock -> queue_lock) and new code in

   net/sunrpc/xprtrdma/svc_rdma_backchannel.c

exposed by my build test.

And looking around, it was reported in linux-next, but you didn't
mention it, which kind of makes the whole reporting pointless.

Guys, what is the point of linux-next if you then don't *react* to it?
The correct reaction is to say during the merge window that "hey,
linux-next showed this issue", just so that I know about it and it
doesn't take me by surprise.

Yes, my normal build tests caught it, and I've fixed up my merge, but
this isn't how things are supposed to work.

                      Linus
