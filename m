Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01F46C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 11:06:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A032C206A2
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 11:06:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726692AbeLQLGX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 06:06:23 -0500
Received: from mail-yb1-f194.google.com ([209.85.219.194]:42777 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726463AbeLQLGX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 06:06:23 -0500
Received: by mail-yb1-f194.google.com with SMTP id m129so4897016ybf.9
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 03:06:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=3eFqRQwiEizojK7ad5qn9xbyPn9WodL71o31OJZXDa4=;
        b=WAlSKw5zLI7hC8VbLMEVb9eEwgwqGrjbIwSEr83POYPnwCwfn4f1fmOiCwZKXQrvhV
         2hxCED1506KxOvqIYq4BJ4Zjw+Uut435laDNswS1o99U4MMmlSCcP6lmX80bLrb/woa/
         Hmt8R1Rz+fGX5rP1RX9MmCmPWd5W492At4IOt4qg2Qq+aGWYzYNuvhZ18LZpk8o3VrFM
         3p0qgn3rzNDKQ3i5fpQ0y66ZWJ0+5nAP117M/ZHpzEpTbIDqNz/8hOsUksXRgn/woupn
         9uBJcKauvUqdr4OrCwLViCluJKDfHVB1e/7RrZcPMJYMaF02F/3IhTdhOQ9X2ue4+tWJ
         CEYw==
X-Gm-Message-State: AA+aEWZDQ/ZJmrQRjEW+kuZtJVO8PgiZOiGWkR6xATLpLb+h5g+sAoDF
        6imzKkxlnoqQQbrft3+VwU4R/Q==
X-Google-Smtp-Source: AFSGD/WSUDeEDFsLuDIAYg0ddDtKce7XMRPJBrsotgaDIwofVXMvVrQL8XMizldiwmfTBLFvJwvjBA==
X-Received: by 2002:a5b:ec3:: with SMTP id a3mr12775101ybs.52.1545044782584;
        Mon, 17 Dec 2018 03:06:22 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-43E.dyn6.twc.com. [2606:a000:1100:db::43e])
        by smtp.gmail.com with ESMTPSA id p201sm5826480ywe.45.2018.12.17.03.06.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 03:06:22 -0800 (PST)
Message-ID: <3ca40f9946c4374e0d118b609c3454ef4c95c3d8.camel@redhat.com>
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
From:   Jeff Layton <jlayton@redhat.com>
To:     Ashish Sangwan <ashishsangwan2@gmail.com>, ffilz@redhat.com
Cc:     linux-nfs@vger.kernel.org, neilb@suse.com
Date:   Mon, 17 Dec 2018 06:06:20 -0500
In-Reply-To: <CAOiN93kfW2H_OEfUGxC4UKJPvn8Lo5Bpkf77UKcxHwWsBwEhXg@mail.gmail.com>
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
         <09842ee0-9948-a5bd-a155-e0d6552b23bb@redhat.com>
         <CAOiN93kfW2H_OEfUGxC4UKJPvn8Lo5Bpkf77UKcxHwWsBwEhXg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-12-14 at 10:41 +0530, Ashish Sangwan wrote:
> On Thu, Dec 13, 2018 at 9:56 PM Frank Filz <ffilz@redhat.com> wrote:
> > On 12/12/18 10:57 AM, Ashish Sangwan wrote:
> > > Hi,
> > > 
> > > Our NFS filer can sometimes return same inode number for different directories.
> > > For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
> > > and dir4 might end up returning the same inode number to the client.
> > > Though it can never happen that inode numbers will be same for two
> > > directories and also there parent is same. Can linux client handle
> > > this case? What issues it can cause?
> > > https://lkml.org/lkml/2006/10/2/346
> > > I stumbled upon this thread where it is written that nfs client can
> > > handle this but userspace will see inode collisions. Given that this
> > > will happen only for directories, userspace utils logic might not get
> > > affected from this as hardlinks on directories are not possible. But
> > > the thread is really old. Wanted to confirm if this holds true even
> > > now.
> > > 
> > > Thanks,
> > > Ashish
> > 
> > The find tool will detect the collisions and report them, and if I
> > recall it stops proceeding down the directory tree from the duplicate
> > inode number. I know for sure I've seen it complain, and pretty sure I
> > saw it stop descending the tree into the directory with the duplicate
> > inode number.
> > 
> 
> True. Was just looking into the find code to check how they detect cycles.
> They are using pair of "device node : inode number" so find will
> certainly complain.
> 

You may also experience problems with some archiving tools -- e.g. tar,
cpio or rsync. Many of those programs rely on looking at inode numbers
to detect hardlinks.

Neil is quite right that the kernel NFS client generally doesn't care
about the inode number though.

-- 
Jeff Layton <jlayton@redhat.com>

