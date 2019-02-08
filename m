Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB423C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:02:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B711E217D8
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:02:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="igqHtqEQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726522AbfBHUC4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:02:56 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:39744 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726700AbfBHUC4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 15:02:56 -0500
Received: by mail-yw1-f68.google.com with SMTP id k188so1855632ywa.6;
        Fri, 08 Feb 2019 12:02:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5Lu2z5qIe9HLYQIczuk11hxCRuBW3S3oIxRGLiSMwqI=;
        b=igqHtqEQfbpqxaanH7duUXYmXwboMiIhsykuFiprWPnCP0fC79HEpkaI9sgRtlHXuf
         VngYn8G+dITYvV9DPqCiLpM0kAUGGGxgaJizylYgjMXi6N4CHbSXdfH8PFKHwYoLMJO5
         lQ0eUX0CnKqR1swYsD16TJI9Wi/EAlGlogOLA6rma4GacoiucPRXmFyC6MYrWRWGlQG4
         Xr5tuttgrbreQVwid0rKnKvlXqJDQ0RVo7ggmBiYtkueQx8w+EOJTLiwaGvrR/X/lqHF
         TAeNn+9y2Ik3cYqloQBG6ekj4CBypFsWENicgxjwcU+FXMo7DNoZ07Un2+DhvEKa/mAJ
         /V3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=5Lu2z5qIe9HLYQIczuk11hxCRuBW3S3oIxRGLiSMwqI=;
        b=EOgklj5AvduzJwh3YEfR5I5s6tf54I637DFDDMk90ikr9KDFo1YtCAwmIqF+yZznKy
         flHoMUjrUqWSx8ZZW4SMrykDrg54F13VWZ3+P4qQgWBwftd1YD9z6/TtNRa0rSwh3xZW
         JyvvtpqrOGm+lb0uH/SBsn4ynJ0jWX3Duh0531VBoR3Y/x4uHBdXxMND+DmZPNZrsZ3F
         Z/sD58sJhNbHdO5hfBsiKr+86hmNiOHNWaoUbPfPcMjPYrEsU5fSdwPoERMQkl/qrBE1
         WFcx4Afq8mkbpmZl7CvjRvoXDzMXt7CXNkeiun7qNLtr+kSxu46obFK8DO93dDu9bbtX
         Eo2Q==
X-Gm-Message-State: AHQUAuYfm/nvQlTdMvUE754wzeICxfC0MoVK7YsuyiWIcZIWxSy9ZCPp
        atFgLrHgpOZ7QM7aDCC+1dvhSZCMdXhcrc868+E=
X-Google-Smtp-Source: AHgI3IYXumkM5mTpFOoEnz4MkpLVILncbyuO8/W735kIguosRd4d5KbGVrY0+DVCJEsyuxbC0prqqr3Q6KN2rr8c/PM=
X-Received: by 2002:a81:6f41:: with SMTP id k62mr18621806ywc.211.1549656175591;
 Fri, 08 Feb 2019 12:02:55 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com> <20190208155052.GB20573@fieldses.org>
In-Reply-To: <20190208155052.GB20573@fieldses.org>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Fri, 8 Feb 2019 22:02:43 +0200
Message-ID: <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Jeff Layton <jlayton@kernel.org>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 8, 2019 at 5:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Feb 08, 2019 at 04:45:46PM +0200, Amir Goldstein wrote:
> > - check_conflicting_open() is changed to use inode_is_open_for_read()
> >   instead of checking d_count and i_count.
>
> Independently of the rest, I'd love to do away with those
> d_count/i_count checks.  What's inode_is_open_for_read()?
>

It would look maybe something like this:

static inline bool file_is_open_for_read(const struct inode *file)
{
        struct inode *inode = file_inode(file);
        int countself = (file->f_mode & (FMODE_READ | FMODE_WRITE)) ==
FMODE_READ) ? 1 : 0;

        return atomic_read(&inode->i_readcount) > countself;
}

And it would allow for acquiring F_WRLCK lease if other
instances of inode are open O_PATH.
A slight change of semantics that seems harmless(?)
and will allow some flexibility.

But if samba can't figure out a way to keep a single open file
descriptor for oplocks per client-file, then this model doesn't
help us make any progress.

Thanks,
Amir.
