Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8B8FC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:59:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52F282083E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:59:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mDWAyPMJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52F282083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726443AbeJYNaL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 09:30:11 -0400
Received: from mail-yb1-f193.google.com ([209.85.219.193]:47021 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726332AbeJYNaL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 09:30:11 -0400
Received: by mail-yb1-f193.google.com with SMTP id o8-v6so3132346ybk.13;
        Wed, 24 Oct 2018 21:59:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iwPJiT4/BFeWah3ZX5bX8Zj8x7uqGZwQ0JgeeVtKPSo=;
        b=mDWAyPMJY4adglv25xj9MCpXMIAXWG8rYMaT+7F0MqNsZFy3uSjdiX7OlXaGNeGQOn
         XZkM82qgigLhWOI0cpKpsfKqLWc2mIo8g/W+c6wsW+G+JbukE4kz0kcUzUg8wrTqJCdr
         SsNLGqJj0j8IQsolII1AxSSgcMmdnGElrF3Yy5j8n+5YZjfUr/qb0NgJvzg4p7uC76PU
         Wq8tt6B9uQ4I3e3/XaJdB3fQN4TBaNHM+WMFuegG335a+JLTE3HEEAAf1LIGu87l1Xk/
         lrvg+HFD3QNBlbszLb6AnqYAGo1XaA90Fo6i7ZjEuN8ViVJBNKk8HYJJxsSy3gDsTu5A
         l/fQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=iwPJiT4/BFeWah3ZX5bX8Zj8x7uqGZwQ0JgeeVtKPSo=;
        b=PZgxUSY1Ru5JUZKIRaEKLj7FbwOZASqvj0ylhoLxw5U0Yesb2lkAc9UILdj8lHOB0f
         uklpA0n6CaAsxQc6X4iCyxCUPu22x97vP9nb2JeuA5I8+ughlC9026zcnMUxGoW0ummK
         MNTN1Pjim0edGb5Syb2kDnpdXA2K1aKqEKcoAPQQoV95WHjK5e848EUggVZAEBEFqBeL
         AyO6bg+ZwXLh00EJAZ1RiwydZVAMT8O9/q4G42lL9y+0OaOgTSEFil6xmWCStd/KMpe7
         mQkpf6agkyoFHL7KjadZLsN/XEUv0E4Qseu/PhIcznHpL7YEvK7pIa5Sn+XqiR7msrWQ
         yqTg==
X-Gm-Message-State: AGRZ1gIqUec00GuU0lDnNydv9Imjbrh+lmtTobgSOfKIJHqLA66jf2Tk
        MbPLcx1Cx/Rx1mCoSz2b/K/7gkkGn6qVJ7/1JA8=
X-Google-Smtp-Source: AJdET5cORQQn6Z4LLnWCPUirRrwZMOA+260OXPYivkxSR8sqY95os/5cvp2q9FBSRfprukOtcMrGx+xmj+8a80B94yk=
X-Received: by 2002:a25:fc0d:: with SMTP id v13-v6mr59879ybd.320.1540443549139;
 Wed, 24 Oct 2018 21:59:09 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
 <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
 <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com>
 <CAN-5tyEtRSQMS-u0gbheFn5f2siOy8Qva2vnXW6rwb7pr_GDkA@mail.gmail.com>
 <CAN-5tyEXvnekZJpOhNBkCBCLTpXjM5PghJxDSeo0dwn94_7wDw@mail.gmail.com>
 <4f35382683c96f03a88c90f0a1fcced36f290d72.camel@redhat.com> <CAN-5tyEQMtWepkhr8m4HjR0pkbbF1a3_-bL4iFJs2xjKervD2A@mail.gmail.com>
In-Reply-To: <CAN-5tyEQMtWepkhr8m4HjR0pkbbF1a3_-bL4iFJs2xjKervD2A@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 07:58:57 +0300
Message-ID: <CAOQ4uxgW+AAxGszy=rsNCZLAJPpJbz6O4Xtnje-=WeDo+oATag@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Jeff Layton <jlayton@redhat.com>,
        Matthew Wilcox <willy@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
[...]
> It feels like folks are now ok with either the check being in the
> drivers or doing the check in the VFS layer.
>
> I'm picking the choice of not doing the check in the VFS layer because
> it allows for do_splice_direct() by any caller.

I'm sorry, but this reasoning in flawed and this is not the reason that
Matthew promoted not doing same fs type check in vfs.
You did not understand the option that I was promoting to begin with.
What I suggested was:

1. Remove current same sb check in beginning of vfs_copy_file_range()
2. Check sb && ->clone_file_range
3. Check same sb type && ->copy_file_range
4. Cross fs do_splice_direct()

It's fine that you chose not to check for same fs type in VFS before calling
copy_file_range() method, but still requires an ACK from Al that he agrees
with passing in file * of another filesystem on the interface.

> I'm about to submit
> the new version of the patches (this time I will include the NFS patch
> series). We can continue with the discussion on the new version.
>
> I have added checks for the CIFS and OverlayFS to be consistent with
> the previous behavior -- no cross-device copy_offload, I assume if and
> when those file systems are ready to make use of it they'll remove the
> check.
>

Actually overlayfs code is "ready" for cross sb copy, but neither nfs nor
cifs are supported as upper file system, so it doesn't matter much.

Thanks,
Amir.
