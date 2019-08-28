Return-Path: <SRS0=/9w8=WY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC4EC3A5A1
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 15:20:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E712022CF8
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 15:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=zadara-com.20150623.gappssmtp.com header.i=@zadara-com.20150623.gappssmtp.com header.b="XrymNvHU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726709AbfH1PUf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Aug 2019 11:20:35 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:33234 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726586AbfH1PUe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Aug 2019 11:20:34 -0400
Received: by mail-io1-f67.google.com with SMTP id z3so382354iog.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2019 08:20:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=zadara-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V7oYmcP6SBUoeMA1SCFbG9LB8sh7NsVOLH35iprwP0Y=;
        b=XrymNvHUK81ywqUCULvdvIemlAo+eOmGtcgN7E6+5qdEJO4AH68DIO800V5OWzE6GT
         y/R9RvoUcocfV+O4iVcKXCzW5iiJ/l9x2qO9aiqwIiDaT8amXl04p6iCUHjEl1CLpD8L
         PXXWKMOZV8P7LimVKw1CQhMVXMJMPItLG6itvk5gig4YU5nuEzHnwz6eRGkIHShTUAkp
         Yno4hoaGr+W9kMLyRYcned1x8xNa7VrdTVzzIOhjKIOV50d9rkAF6IRyZWy1/sVPWwds
         Hu9gfcdKhT60cyw8yomxjbx0dHQn3+YSMPnW1SijYnpL7TIe382xWIMwJVqn+xnVb6tw
         O0Jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=V7oYmcP6SBUoeMA1SCFbG9LB8sh7NsVOLH35iprwP0Y=;
        b=S18rZG9bmQi9+AO4CkNj9xiYmxYOUrZJnW6Pwn5/zKJBjm1iqM7hlPWiYjUU3Rgy59
         uqn6t3js5nh+8CzMky5FuWpQCw0NUzy8FAztYeXGQUSQadxb6hOuLyDiH7LfXRQHs0eA
         VUhSV+yiSzPKAYJocruQfRNHsjZNitdC7jqSfHs1VxWKz8VfhRi3s9NXCJRMaoA27jSC
         sfZHXGUhlCEncqGVzpPwTEHJDZRW3+5TIo+Bi/6xznauRqAkNjCrOjY+ZrUofObXZxxB
         b9/9xPPnvnOgghb7ZcnhiCXG223vA1UtV6Msr+KhGYn8luGv+M/f8m/u3sDqDiXyyIEL
         Jbvw==
X-Gm-Message-State: APjAAAUFQSG3yBDz+DeHKEZvK4Q3rpfXfRfPeLErpx0sp/QmpDjDEfUH
        etKmvl/yybT5SMKj76EEKd8fnggNLkuxFyBIslXq9A==
X-Google-Smtp-Source: APXvYqxcDGPW8JRPmQjcsGbo6VE0c0TPK4aa+kviZEth9siaYCud2jiqQOEEA+5yQgjvgrnV9EcPgN+ALMWltXY/RCY=
X-Received: by 2002:a6b:f30b:: with SMTP id m11mr4850113ioh.214.1567005634114;
 Wed, 28 Aug 2019 08:20:34 -0700 (PDT)
MIME-Version: 1.0
References: <1566406146-7887-1-git-send-email-alex@zadara.com>
 <CAOcd+r0bXefi79dnwrwsDN1OecScfTjc8DYS5_9A8D5XKrh7QQ@mail.gmail.com>
 <20190826133951.GC22759@fieldses.org> <CAOcd+r059fh7J8T=6MdjPSCP39K5fpOZTsXZDUKq5TrPv_RcVQ@mail.gmail.com>
 <20190827205158.GB13198@fieldses.org>
In-Reply-To: <20190827205158.GB13198@fieldses.org>
From:   Alex Lyakas <alex@zadara.com>
Date:   Wed, 28 Aug 2019 18:20:22 +0300
Message-ID: <CAOcd+r0Ybfr1WszjYc1K19Cf7JmKowy=Go6nc8Fexf5KxNyf=A@mail.gmail.com>
Subject: Re: [RFC-PATCH] nfsd: when unhashing openowners, increment
 openowner's refcount
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Shyam Kaushik <shyam@zadara.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Bruce,

Thanks for the clarifications.

On Tue, Aug 27, 2019 at 11:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Aug 27, 2019 at 12:05:28PM +0300, Alex Lyakas wrote:
> > Is the described issue familiar to you?
>
> Yep, got it, but I haven't seen anyone try to solve it using the fault
> injection code, that's interesting!
>
> There's also fs/nfsd/unlock_filesystem.  It only unlocks NLM (NFSv3)
> locks.  But it'd probably be reasonable to teach it to get NFSv4 state
> too (locks, opens, delegations, and layouts).
>
> But my feeling's always been that the cleanest way to do it is to create
> two containers with separate net namespaces and run nfsd in both of
> them.  You can start and stop the servers in the different containers
> independently.

I am looking at the code, and currently nfsd creates a single
namespace subsystem in init_nfsd. All nfs4_clients run in this
subsystem.

So the proposal is to use register_pernet_subsys() for every
filesystem that is exported? I presume that current nfsd code cannot
do this, and some rework is required to move away from a single
subsystem to per-export subsystem. Also, grepping through kernel code,
I see that namespace subsystems are created by different modules as
part of module initialization, rather than doing that dynamically.
Furthermore, in our case the same nfsd machine S can export tens or
even hundreds of local filesystems.Is this fine to have hundreds of
subsystems?

Otherwise, I understand that the current behavior is a "won't fix",
and it is expected for the client machine to unmount the export before
un-exporting the file system at nfsd machine. Is this correct?

Thanks,
Alex.


>
> > It is very easily reproducible. What is the way to solve it? To our
> > understanding, if we un-export a FS from nfsd, we should be able to
> > unmount it.
>
> Unexporting has never removed locks or opens or other state, for what
> it's worth.
>
> --b.
