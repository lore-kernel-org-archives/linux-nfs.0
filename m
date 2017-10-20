Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54732 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752963AbdJTTTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 15:19:35 -0400
Date: Fri, 20 Oct 2017 15:19:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Jeff Layton <jlayton@redhat.com>,
        y2038 Mailman List <y2038@lists.linaro.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfds: avoid gettimeofday for nfssvc_boot time
Message-ID: <20171020191935.GE15211@fieldses.org>
References: <20171019100435.1170955-1-arnd@arndb.de>
 <1508410486.4912.11.camel@redhat.com>
 <CAK8P3a0K0FcepYtxw-6sct0b5ZTx4b+TW9bF9uqL5HV_M03H-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAK8P3a0K0FcepYtxw-6sct0b5ZTx4b+TW9bF9uqL5HV_M03H-w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 01:04:35PM +0200, Arnd Bergmann wrote:
> On Thu, Oct 19, 2017 at 12:54 PM, Jeff Layton <jlayton@redhat.com> wrote:
> >
> > I wonder if we'd be better off just using nfssvc_boot.tv_sec as the
> > verifier? I don't see us ever calling that ktime_get_real_ts64 more than
> > once per second for this purpose, and that would eliminate wraparound.
> > That said, wraparound is not a huge concern here anyway, so this is
> > certainly fine for now:

It might reduce the chances of a collision if someone is doing extreme
boot-time optimization, or if time goes backwards for some reason?

> I now have the feeling that we had previously had the same discussion
> when someone else submitted a similar patch that ended up never getting
> merged. I might also be confusing this with a different subsystem that
> had the same requirement.
> 
> If we want this to be as unique as possible and also never (within
> a few hundred years) wrap, we could call ktime_get_real_ns(), which
> returns a 64-bit nanoseconds number.

Anyway, no objection to doing this differently if someone wants, but
I'll just take this patch for now.

Thanks.--b.

> 
> > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> 
> Thanks.
> 
>      Arnd
