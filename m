Return-Path: <SRS0=Gfnv=W6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9EC3C3A5A2
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 13:48:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A8E6208E4
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 13:48:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=zadara-com.20150623.gappssmtp.com header.i=@zadara-com.20150623.gappssmtp.com header.b="rqnEAeia"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729090AbfICNsA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Sep 2019 09:48:00 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:33147 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729053AbfICNr7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2019 09:47:59 -0400
Received: by mail-io1-f67.google.com with SMTP id m11so4032091ioo.0
        for <linux-nfs@vger.kernel.org>; Tue, 03 Sep 2019 06:47:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=zadara-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=inUKcmpWbh/HUj7RWRku+upx/KHyut+wTijgbqKDOuE=;
        b=rqnEAeiaqbV3qthDMnEVsywwaLE7A/RJU2jLRNX3yzY9o2GkOuX+zH7AefsOif+JmS
         uuQdviRqhtlHzfnhnsGaGz2xWTGV+8zCorEobtn/1BhCicZzK8d33SOsymBwa21qQNH4
         nv9Tu1hprWK2j8VSJ3fXvqd35YGnlvdu3xXCkR8WvMfOxFF4HgWHBGCM+ec5sVa1yQSG
         d54COrKCWVYPgx2IuWlDkb7yFJDCZRhUns9VXLEgURGCdHLrwad5rsE2HG0Oqxd1Jj3a
         Zmc0P/b4GDQPbJh8TPmuG7roG12JIGLUYn44s70dCoAkR2TkixEv1H7jc86jeQj0piR0
         HhvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=inUKcmpWbh/HUj7RWRku+upx/KHyut+wTijgbqKDOuE=;
        b=aSuEgXQhJvLSNCWJ7QzIbBO8xoqH7Z1vLnTWwMEdGltO+S9+wKWD8LT5MgB5huH5Y2
         GgmrtZTSJmbEOmVSGA5q9kxAByjdbQ7TjrLDW+rZv8/ZT2D+N/g35vf7ETCv38z3W6q+
         HDOa4/iCtJRa34lWXOZa8f0v1FKjCVZRMSKjiN1NmOmnHQlnw5UGMKPxJyVoS2923Cbk
         gD50Ga3AkmGNUnw7a7jVmGcXAyDCRo4lULMKUxyV+5x4HiaaOPou7JFlW4ZmAP2eeUOI
         RiAbRpOa/oge3EcfWhGBZExyOjuMAVcMLOARINXHS4PlPLv27x7s23yJ9bGgvS+QsB+q
         gdIQ==
X-Gm-Message-State: APjAAAXB/5rjEnxO+AsRDHODesAr5GE7OqVTJUBd5Ww30NaPmo+hLgCM
        8hH3bD5edIXeHBdrFhT53bKujyLflctODe0/3fRL7A==
X-Google-Smtp-Source: APXvYqylKE3i13iJkmBnmlbutRp7Vr7E0v0CYSYtiIyQLq8pk/J+wy6eYAyLmmJoChmd2c+dbTzNoST51RAF1Wsdy9E=
X-Received: by 2002:a6b:7f07:: with SMTP id l7mr10247626ioq.167.1567518478974;
 Tue, 03 Sep 2019 06:47:58 -0700 (PDT)
MIME-Version: 1.0
References: <1566406146-7887-1-git-send-email-alex@zadara.com>
 <CAOcd+r0bXefi79dnwrwsDN1OecScfTjc8DYS5_9A8D5XKrh7QQ@mail.gmail.com>
 <20190826133951.GC22759@fieldses.org> <CAOcd+r059fh7J8T=6MdjPSCP39K5fpOZTsXZDUKq5TrPv_RcVQ@mail.gmail.com>
 <20190827205158.GB13198@fieldses.org> <CAOcd+r0Ybfr1WszjYc1K19Cf7JmKowy=Go6nc8Fexf5KxNyf=A@mail.gmail.com>
 <20190828165429.GC26284@fieldses.org> <CAOcd+r3e52q_ds3zjya98whYarqoXf5C2umNEX-AGp4-R6=Cuw@mail.gmail.com>
 <20190830190804.GB5053@fieldses.org>
In-Reply-To: <20190830190804.GB5053@fieldses.org>
From:   Alex Lyakas <alex@zadara.com>
Date:   Tue, 3 Sep 2019 16:47:47 +0300
Message-ID: <CAOcd+r2+uC_T6mhb-7s2p_xd762Ki+KNA=GjNUXtUYAZJknQ-w@mail.gmail.com>
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

On Fri, Aug 30, 2019 at 10:08 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Aug 29, 2019 at 09:12:49PM +0300, Alex Lyakas wrote:
> > We evaluated the network namespaces approach. But, unfortunately, it
> > doesn't fit easily into how our system is currently structured. We
> > would have to create and configure interfaces for every namespace, and
> > have a separate IP address (presumably) for every namespace.
>
> Yes.
>
> > All this
> > seems a bit of an overkill, to just have several local filesystems
> > exported to the same client (which is when we hit the issue). I would
> > assume that some other users would argue as well that creating a
> > separate network namespace for every local filesystem is not the way
> > to go from the administration point of view.
>
> OK, makes sense.
>
> And I take it you don't want to go around to each client and shut things
> down cleanly.  And you're fine with the client applications erroring out
> when you yank their filesystem out from underneath them.
It's not that we don't want to unmount at each client. The problem is
that we don't control the client machines, as they are owned by
customers. We definitely recommend customers to unmount, before
un-exporting. But in some cases it still doesn't happen, most notably
in automated environments. Since the un-export operation is initiated
by customer, I presume she understands that the nfs client might error
out, if not unmounted properly beforehand.

>
> (I wonder what happens these days when that happens on a linux client
> when there are dirty pages.  I think you may just end up with a useless
> mount that you can't get rid of till you power down the client.)
Right, in some cases, the IO process gets stuck forever.

>
> > Regarding the failure injection code, we did not actually enable and
> > use it. We instead wrote some custom code that is highly modeled after
> > the failure injection code.
>
> Sounds interesting....  I'll try to understand it and give some comments
> later.
> ...
> > Currently this code is invoked from a custom procfs entry, by
> > user-space application, before unmounting the local file system.
> >
> > Would moving this code into the "unlock_filesystem" infrastructure be
> > acceptable?
>
> Yes.  I'd be interested in patches.
>
> > Since the "share_id" approach is very custom for our
> > usage, what criteria would you suggest for selecting the openowners to
> > be "forgotten"?
>
> The share_id shouldn't be necessary.  I'll think about it.
>
> --b.
