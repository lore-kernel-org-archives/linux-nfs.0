Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98613C04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 13:24:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52AFD2146D
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 13:24:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gPzQPWQq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52AFD2146D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726619AbeLBAgk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 19:36:40 -0500
Received: from mail-ua1-f68.google.com ([209.85.222.68]:46936 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726570AbeLBAgk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 19:36:40 -0500
Received: by mail-ua1-f68.google.com with SMTP id v24so2877998uap.13;
        Sat, 01 Dec 2018 05:24:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R79mlcZhIVIhg77hJ/LJB3vN0/PwuES5ACAGOFXRJ2c=;
        b=gPzQPWQq4GJ8+z1QR4F/+N8uhX3ejawMaDWSAbVx9ox4+YQzanlgxXYb4CvOXzGc2e
         pB73UbimGqn8Szv2b5Vh2kwzrMkaqIeilnYhG7XaYMfXcT6fuxvVOBKr2R9P1Qj/lOtG
         va8PphDL4UAaxpJCj2+6xidn94UbneDv1BmtxX4hOGc583EckWPE/DJeZyMvZLCYuIfU
         j62+C2KTiNXpFmx55sG9bHqSYi9ANZqWEzqrz4nEqrpk6oNeR7vNCId6IwiSRw38LhCQ
         mXCZ/WXFJY6JotUKw5Wqg5Tryu5kG9fRZiwQ8TNCVx1ak32ZR7LFU5zhq7wMwYlgS4Od
         z4Pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=R79mlcZhIVIhg77hJ/LJB3vN0/PwuES5ACAGOFXRJ2c=;
        b=pN3CuSDyuIIme+N/UggOKa5UoIjFMoqajdCfDhkjpY9DoB9pk4H3B2QZaQQMw1JZcK
         XMWpLn6/tEpoe82tAxgGISFjbf58zabY3kAz3Yf/bXpGAd/IWSAbTFZdsSah5T+KNXIv
         oQ0Oqp2E9RtUquElBrb7KtPVxU1dLTBZBsBg1TOb3jmUU+IDUwlaiZ/uVlJypGY6BpI9
         dWgyEgZcWfCcCeBJdzd6leBkIOLfBOMPWIOYv82yhx78EDyglPlNMs9zWCbopT8TlpjT
         Aljzqkq4jsV2UGdaHA6iGH10sS76ayiNCjm56dU/ygAKEz0YMu2MkPKcz55PRCWlVOi7
         n4UQ==
X-Gm-Message-State: AA+aEWaEucTaCx4dQAuQJuekax4hRNywdBzxzsJ6iPIKthzoIkDFppRs
        LcNBxsGTngGfG1U7WUxjisSGNTSt9vwya4pQhJ8=
X-Google-Smtp-Source: AFSGD/X2T4tqDRpdJKpxRxMbE6478QLBotI3SZZr/Kz8P/SdfYLe08aovbhyh6qUU2NyJgTJCK22sS4t3VYS1h2Ak+c=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr4064051uam.104.1543670647716;
 Sat, 01 Dec 2018 05:24:07 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com> <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
In-Reply-To: <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Sat, 1 Dec 2018 08:23:56 -0500
Message-ID: <CAN-5tyGV1F6EAwN3e3dHyvfL6UJhJu1m=GKCT4iVMy6uprcS+w@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, david@fromorbit.com,
        willy@infradead.org, jlayton@kernel.org, stfrench@microsoft.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 1, 2018 at 3:11 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > Relax the condition that input files must be from the same
> > file systems.
> >
> > Add checks that input parameters adhere semantics.
> >
> > If no copy_file_range() support is found, then do generic
> > checks for the unsupported page cache ranges, LFS, limits,
> > and clear setuid/setgid if not running as root before calling
> > do_splice_direct(). Update atime,ctime,mtime afterwards.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
>
> This patch is either going to bring you down or make you stronger ;-)
>
> This is not how its done. Behavior change and refactoring mixed into
> one patch is wrong for several reasons. And when you relax same sb
> check you need to restrict it inside filesystems, like your previous patch
> did.
>
> You already had v7 patch reviewed-by 4 developers.
> What made you go and change it (and posted as v2)?
>
> Your intentions were good trying to fix the broken syscall, but
> I hope you understood that Dave didn't mean that you *have* to
> add the missing generic checks as part of your work. He just
> pointed out how broken the current interface is in the context of
> reviewing your patch.
>
> In any case, I hear that Dave is neck deep in fixing copy_file_range()
> so changes to this function should be collaborated with him. Or better
> yet, wait until he posts his fixes and carry on from there.
>
> If I were you, I would just go back to the reviewed v7 vfs patch.

This is NOT a replacement to the v7 vfs patch??? This is a new patch
on top of that one.

I assume that v7 patch has been OK-ed by everybody and is ready to go in???

As you recall, what was left is to provide the functionality to relax
the check for the superblocks to be the same before calling the
do_splice_direct(). This patch attempt do this. I was under the
impression that to do so extra checks were needed to be added which I
added.


>
> Thanks,
> Amir.
