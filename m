Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:34762 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753990AbcHSFfA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 01:35:00 -0400
Received: by mail-ua0-f179.google.com with SMTP id k90so63587525uak.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 22:34:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <173CD366-84D2-42B5-8903-3B5E5131095B@oracle.com>
References: <CA+X5Wn4f8b+DXGT-OpPWmF=uZ=8m+mh27SfCJNMrven_DZtRVg@mail.gmail.com>
 <173CD366-84D2-42B5-8903-3B5E5131095B@oracle.com>
From: james harvey <jamespharvey20@gmail.com>
Date: Fri, 19 Aug 2016 01:06:38 -0400
Message-ID: <CA+X5Wn6eGxib1GzmfbWMgNsuvu4HXYrh_iBTdgNR+0oPLu_Vdg@mail.gmail.com>
Subject: Re: Is NFSv4.2 now compatible & stable with rdma?
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Full sparse support would be nice, but certainly not critical.  I'd
rather stay with what was considered least problematic.

I'm re-examining any workarounds we use, to see if any of the issues
have been resolved so any workarounds are no longer needed.  As a
general rule, without a reason to do otherwise, I like letting
something run with defaults (where it would pick 4.2) rather than
overriding something.

So, with RDMA on 4.7.1+, no reason to stay on NFSv4.0 instead of NFSv4.1?

On Thu, Aug 18, 2016 at 11:26 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi James-
>
>
>> On Aug 18, 2016, at 12:09 AM, james harvey <jamespharvey20@gmail.com> wrote:
>>
>> A year ago, on 7/30/2015, Chuck Lever said NFS/RDMA wasn't yet working
>> with NFSv4.1 and NFSv4.2, as a known issue.
>>
>> I was able to use "vers=4.0" to get around the issue.
>>
>> I see v4.2 seems to mount properly, but before switching over to it, I
>> wanted to see if it's considered stable, or still to be avoided.
>
> Can you tell why you'd like to use it? Which NFSv4.2 feature is interesting
> to you?
>
> I don't test it regularly, simply because
>
> - The complete tests on each version take a long time to run
>
> - NFSv4.2 features are all optional, and the Linux NFSv4.2 implementation
> adds only a couple that probably won't be affected by RDMA. READ_PLUS will
> need some attention at some point, but I think Anna is still polishing the
> upper layer implementation.
>
> - I don't have any specific tests for security labels, which add to the
> size of the NFSv4 GETATTR receive buffer whether labels are actually
> retrieved or not. So there is a little NFSv4.2 testing we get for free just
> by using NFSv4.0.
>
> - There's yet a lot of non-version-specific work to do on RPC-over-RDMA.
>
> The main blocker before was support for bi-directional RPC, which all
> minorversions of NFSv4 use after mv 1, and that should be working as well
> as it does for NFSv4.1.
>
> NFSv4.2 itself should work, but I might choose to stay with NFSv4.1 for
> now if it were up to me, unless you have need of one of the new features.
> For example, there is no standard specification describing how READ_PLUS
> is supposed to work on RPC-over-RDMA (that's in the works).
>
>
> --
> Chuck Lever
>
>
>
