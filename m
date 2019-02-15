Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43B6EC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 09:49:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1890A2070D
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 09:49:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388842AbfBOJtd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 04:49:33 -0500
Received: from mail-yb1-f175.google.com ([209.85.219.175]:33972 "EHLO
        mail-yb1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2393468AbfBOJt1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 04:49:27 -0500
Received: by mail-yb1-f175.google.com with SMTP id j62so3571729ybb.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2019 01:49:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=4hq6xqYLYiYwjVz/aUUvZmg70Axi8WOBYg5m1LDoRZ4=;
        b=q6o/zJ4sFFrQPmKn6Vi2fQN48RKN0zSnldLDfKuX1W+XaExAgd67n4lAk2snLZzfvz
         N4x8Z9Cti0SOk6AtSAYvXCq3Wm1/KH/txNdT9dNEdxIp1L+ZeXGhUxqtdK1K/PsrGGls
         pal81fHi30FePzjIP7ERmKteiEsgD8LqdiRklZvLPKrGVGCiMA5oEuaXtydOkbTNQCpa
         JTY6EVUBkDyR2Bz2UC7HnCkv9gIJ4rcHAHwULl/VoGB/BLeOuovl0IEpY5CSmVDOoSzF
         +Ucx0KCfIPEEmQy26nAUjP7xZlCiIF1b3Syk/kKyi4BdApuS+i4fiSzLphhflSppYHTs
         lmew==
X-Gm-Message-State: AHQUAuaoiCS/pONyYwnKlGZqIjduMwAk5bkHtqLao4oZw0sd2fOYPns1
        UQ/diGjwAaVN/sK93Ggt2p6Z7qUfWGI=
X-Google-Smtp-Source: AHgI3IarY3g5fbsxaobW59CPdgk/517+UXyvdlVSt4oucxqvmPhk5Qe4p7s3oW+562aUQqu0v6DJOw==
X-Received: by 2002:a25:3b82:: with SMTP id i124mr7110784yba.183.1550224166478;
        Fri, 15 Feb 2019 01:49:26 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-C3D.dyn6.twc.com. [2606:a000:1100:db::c3d])
        by smtp.gmail.com with ESMTPSA id n67sm244871ywn.1.2019.02.15.01.49.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 15 Feb 2019 01:49:25 -0800 (PST)
Message-ID: <ab5c96681e62be6ca79e7464c1141106b6d5fbce.camel@redhat.com>
Subject: Re: Why doesn't NFSv3 implement LOOKUPP?
From:   Jeff Layton <jlayton@redhat.com>
To:     Yihao Wu <wuyihao@linux.alibaba.com>, linux-nfs@vger.kernel.org
Date:   Fri, 15 Feb 2019 04:49:25 -0500
In-Reply-To: <2a2b8156-69c1-ad7f-6000-716f28690fb7@linux.alibaba.com>
References: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
         <0bd905c30a652d19404eef82b40f6b92987ca814.camel@redhat.com>
         <2a2b8156-69c1-ad7f-6000-716f28690fb7@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-15 at 13:14 +0800, Yihao Wu wrote:
> On 2019/2/13 7:50 PM, Jeff Layton wrote:
> > On Wed, 2019-02-13 at 16:41 +0800, Yihao Wu wrote:
> > > Hi all,
> > > 
> > > When looking into "Failures: generic/467" given by xfstests, I found that NFSv3
> > > didn't implement LOOKUPP. I know that this might be by design. But LOOKUPP was
> > > meant to replace ".." in NFSv3, right?
> > > 
> > > xfstests's generic/467 test case performs the following sequence of operations.
> > > 
> > > name_to_handle -> drop_caches -> open_by_handle
> > > 
> > > Dentry becomes disconnected due to drop_caches. NFSv3 doesn't support LOOKUPP.
> > > So when it performs open_by_handle to an directory, this test case fails.
> > > 
> > > I did some small experiment by implementing LOOKUPP for NFSv3. The way I tried
> > > is to merely pass ".." to nfs3_proc_lookup. And it seems to work. At least it's
> > > a workaround for xfstests.
> > > 
> > > I'm curious whether this sort of simulation of LOOKUPP will work or make sense.
> > > 
> > > Thanks,
> > > Yihao Wu
> > 
> > v3 was mostly designed with unix-like clients in mind. For v4, the spec
> > writers cast a wider net and decided not to put special meaning on
> > lookups of "." and "..", but they still needed a way to do a lookup of
> > "..".
> > 
> > The question is why you want to implement LOOKUPP in v3. Mostly we added
> > it to the client to support reexporting NFSv4 filesystems via NFSv3. Are
> > you looking to reexport v3 filesystems for some reason?
> > 
> 
> Thanks a lot for your reply, Jeff!
> 
> I'm just managing to figure out the source of this xfstests failure, that
> open_by_handle is simply not working for NFSv3 after drop_caches. I think NFSv3
> might become able to reconnect_path too, with LOOKUP "..". However it's not,
> because nfs_get_parent fails as long as LOOKUPP is not supported.
> 
> My server & client both support NFSv3. Can I take it that re-exporting is not a
> required option in this case?

Yes, I don't think we're too interested in reexporting v3.

The open_by_handle_at call is mostly there to support userland NFS
servers (though there are some other legit use-cases). If you're not
planning on reexporting NFSv3, then those failures probably won't matter
much.

If you do have need to use open_by_handle_at on NFSv3 for some
legitimate purpose, then we could certainly look at patching that up in
some fashion.
-- 
Jeff Layton <jlayton@redhat.com>

