Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D029DC04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 17:02:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 954832084C
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 17:02:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tOHc7OeL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 954832084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727436AbeLERB7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 12:01:59 -0500
Received: from mail-ua1-f66.google.com ([209.85.222.66]:41128 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727240AbeLERB7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 12:01:59 -0500
Received: by mail-ua1-f66.google.com with SMTP id z24so7356122ual.8;
        Wed, 05 Dec 2018 09:01:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kgm5BRqN9FpvQPYSdOF+ddbRCItq2qAVwsZL93bGdlM=;
        b=tOHc7OeLmUspCZxJKoKd1KmO+RyMyJzedke1E2Z6LpLcs/HjNM5yaDAjaFmswLIoLc
         SpKbEgWJkzP8Q0wtD2F9DDlGXVus+ncCRYKoQ5lqRMN8lrbwxqRonv4El+7F4NHOzJRc
         UX+suIEPtu0d8K1fIq1z3sqHpOsg+A9VpZOG0HT7QYh6VuNEVoEuo4PZ0oeC5z49A0ah
         a1GLHMc4BSHnl4deSs6O6Nr5YsrPrxH0IwbuEjl+DH84C3ZTSZksO65wsKNGfyp3T7T5
         Zo2DVYMUxEDhHRGQp8eJQghyC/iKFF/OGbig9Vzjv3FtxPtOwdgkQXo/Wz23V8rBdcAr
         OlkA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=kgm5BRqN9FpvQPYSdOF+ddbRCItq2qAVwsZL93bGdlM=;
        b=dfuvtLYki84Mhn9syy+oqbZMvjfulc7R84k5xaG0OZpu+LDw+WlanGS51eVJjAaRHE
         assb4V4vb+bfMdMkSerVG9+VuvTQtIpYbozTeAvJCVLnhN9f8OG3WUkB0qgR4nmmwwiU
         rBHKfK7yUwXHziscEKmVzQ+Bif2zqjtHYV0XlF6qpyITNmErMdUOTz5NIrKf5jCu5YVn
         i5nYH5rYUQKd6qk3QGoEjjDDspGWgjiC9z1O8Bg8ohbL+0zdrFjdw7lL4DhOrLk0Dlw7
         h43E1SO751EgmOImto0DQhQBQchyaCkI1DE71XfYpdC9WPqV+o4gw/Z3ESF5O3z0yked
         kKzw==
X-Gm-Message-State: AA+aEWZ8Xv/ivUAiNZuJjajj47srG8aTqhl1v3lbtQ3ZUwtWzqfymmgl
        SFt67tSU3OfblHuKEF2YByFBLMunmASBQbvKqRY=
X-Google-Smtp-Source: AFSGD/Xk87ahKtyMnJ9jdfSuDPQvMM3nF+dsbv+2TYrQOzEmOLFMXvw3UfbQBQ/mpvCVKHp8cvWhAX8i7hSjKrRfX9o=
X-Received: by 2002:ab0:aa:: with SMTP id 39mr11119996uaj.120.1544029317566;
 Wed, 05 Dec 2018 09:01:57 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-10-david@fromorbit.com>
 <20181204154347.GA6925@infradead.org> <20181204221847.GQ6311@dastard> <20181205140925.GA21109@infradead.org>
In-Reply-To: <20181205140925.GA21109@infradead.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 5 Dec 2018 12:01:45 -0500
Message-ID: <CAN-5tyEuEidvyjmOUpc7zM=JgWsDpaoiBtzywDBC4TXmxVxxKw@mail.gmail.com>
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
To:     Christoph Hellwig <hch@infradead.org>
Cc:     david@fromorbit.com, linux-fsdevel@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 5, 2018 at 9:09 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Wed, Dec 05, 2018 at 09:18:47AM +1100, Dave Chinner wrote:
> > I'll drop it if you want, but then I'll just have to come back after
> > all the NFS code is merged and do yet more cleanup work.
>
> IFF we want these NFS "features" we'll have to get it right before
> merging the code.  But even with that I'd rather fix the glaring
> issues you are fixing in your first patches as a priority before
> adding more features.  In other words:  don't worry about NFS, lets
> get the existing code right before worrying about the next round
> of potential issues.

Dave,

Do you mind in v2 removing the 'retry, ret=EAGAIN' piece and leave the
call to the nfs42_copy_file_range() (with the superblock block check)?
If not, I could provide the patch.

This is a piece of code that got in as a part of the async copy
patches and it was meant for the upcoming server-to-server series.
This code will go right back in with the next series. But since dead
piece of code is glaring wrong currently by all means let's fix it.

Thank you.
