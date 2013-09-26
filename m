Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:35498 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730Ab3IZSfr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:35:47 -0400
Received: by mail-ve0-f180.google.com with SMTP id jz11so1212280veb.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:35:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130926174742.GA5066@fieldses.org>
References: <42.19.15034.896B3425@epcpsbgx2.samsung.com>
	<20130926174742.GA5066@fieldses.org>
Date: Thu, 26 Sep 2013 11:35:46 -0700
Message-ID: <CABgxfbHyE04V_7YH2Zcqm+TAgCjT73kKWVGmKD30YxsriT+FMw@mail.gmail.com>
Subject: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS v4.2
 support to the NFS server")
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jongman Heo <jongman.heo@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 10:47 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> (BTW, out of curiosity: what kind of client is this that only supports
> NFSv2 and NFSv3?  Even for an embedded system that's a bit surprising.)
>

There are few floating around - at least I'm working on one at this moment.

Look to me the upgrade issue is with user space packages (e.g. where
"mount" lives). Embedded systems can take their user space packages
from certain "distribution"s that are not necessarily sync well with
individual linux upstream tool distribution, even the kernel itself is
reasonably updated.

And don't shoot a messenger :) .. I'm just describing the practices I
have been observed.

-- Wendy
