Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34413 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdEJUGP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 16:06:15 -0400
MIME-Version: 1.0
In-Reply-To: <1494434821.4764.1.camel@primarydata.com>
References: <1494434821.4764.1.camel@primarydata.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 May 2017 13:06:13 -0700
Message-ID: <CA+55aFwGseGd8jYdU_FAKvD5G66h_uzdDjkYvc-3eheiaTszmw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 10, 2017 at 9:47 AM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
> Features:
> - Removal of the unmaintained and unused OSD pNFS layout
> - Cleanup and removal of lots of unnecessary dprintk()s
> - Cleanup and removal of some memory failure paths now that
> ..
>  56 files changed, 949 insertions(+), 2960 deletions(-)

Lovely. Thanks,

                    Linus
