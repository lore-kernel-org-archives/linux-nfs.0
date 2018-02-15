Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55948 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1424630AbeBOQDF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Feb 2018 11:03:05 -0500
Date: Thu, 15 Feb 2018 11:03:05 -0500
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Cc: bfields@redhat.com, trondmy@primarydata.com,
        luxy.fnst@cn.fujitsu.com, linux-nfs@vger.kernel.org
Subject: Re: Questions about pynfs:testLargeData-WRT5
Message-ID: <20180215160305.GC9999@fieldses.org>
References: <20180209183112.GC30030@parsley.fieldses.org>
 <6c3159af-17c5-5556-d416-574968bb5e14@cn.fujitsu.com>
 <738139ab-6a55-4c93-008d-56a2332774c9@jp.fujitsu.com>
 <20180213161540.GA26270@parsley.fieldses.org>
 <20180214154909.GA32456@parsley.fieldses.org>
 <225b853a-d388-f281-0902-d34f998210bf@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <225b853a-d388-f281-0902-d34f998210bf@jp.fujitsu.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 15, 2018 at 11:08:51AM +0900, Seiichi Ikarashi wrote:
> How about the name "testMaximumData()" or something?
> It's not just "Large".
...
> > +def testTooLargeData(t, env):
> > +    """WRITE with more than the maximum size
> 
>                 with 10^6 bytes beyond the maximum size

Both done, thanks.--b.
