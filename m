Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:36345 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790AbbJHMyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 08:54:53 -0400
Received: by ykba192 with SMTP id a192so43391214ykb.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2015 05:54:53 -0700 (PDT)
Message-ID: <1444308880.43040.1.camel@primarydata.com>
Subject: Re: RCU caching regression in kernel v4.1+
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, lawa@nvidia.com,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>
Date: Thu, 08 Oct 2015 08:54:40 -0400
In-Reply-To: <CAHQdGtQTDeYN4ZQn8=zV4WwTQG-FWoLNb4H-kTwJo_nRsy3g6g@mail.gmail.com>
References: <CAHQdGtQTDeYN4ZQn8=zV4WwTQG-FWoLNb4H-kTwJo_nRsy3g6g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-10-07 at 14:57 -0400, Trond Myklebust wrote:
> Hi Al,
> 
> Please could you take a look at the bugzilla entry in
> https://bugzilla.kernel.org/show_bug.cgi?id=104911 ?
> 
> It describes a NFS caching regression that appears to be caused by
> commit 766c4cbfacd8634d7580bac6a1b8456e63de3e84 ("namei:
> d_is_negative() should be checked before ->d_seq validation").
> 
> Shouldn't that test for 'if (negative) return -ENOENT;' happen after
> the call to d_revalidate() in lookup_fast()? If not, we can end up
> caching negative dentries forever, AFAICS...
> 
> Cheers
>   Trond

Leandro, can you please test if the following patch helps in any way?

Cheers
  Trond

8<-----------------------------------------------------------------
