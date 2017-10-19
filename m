Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:46458 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdJSLEg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 07:04:36 -0400
MIME-Version: 1.0
In-Reply-To: <1508410486.4912.11.camel@redhat.com>
References: <20171019100435.1170955-1-arnd@arndb.de> <1508410486.4912.11.camel@redhat.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 19 Oct 2017 13:04:35 +0200
Message-ID: <CAK8P3a0K0FcepYtxw-6sct0b5ZTx4b+TW9bF9uqL5HV_M03H-w@mail.gmail.com>
Subject: Re: [PATCH] nfds: avoid gettimeofday for nfssvc_boot time
To: Jeff Layton <jlayton@redhat.com>
Cc: y2038 Mailman List <y2038@lists.linaro.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 12:54 PM, Jeff Layton <jlayton@redhat.com> wrote:
>
> I wonder if we'd be better off just using nfssvc_boot.tv_sec as the
> verifier? I don't see us ever calling that ktime_get_real_ts64 more than
> once per second for this purpose, and that would eliminate wraparound.
> That said, wraparound is not a huge concern here anyway, so this is
> certainly fine for now:

I now have the feeling that we had previously had the same discussion
when someone else submitted a similar patch that ended up never getting
merged. I might also be confusing this with a different subsystem that
had the same requirement.

If we want this to be as unique as possible and also never (within
a few hundred years) wrap, we could call ktime_get_real_ns(), which
returns a 64-bit nanoseconds number.

> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks.

     Arnd
