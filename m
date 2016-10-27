Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33982 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932388AbcJ0BFh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Oct 2016 21:05:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id y138so179536wme.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Oct 2016 18:05:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161020143603.GC2733@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <CALXu0UdS_m6ag7VDdbc-aJWH+fK=42GM0FEWH1Ht9M-9xy9Xjw@mail.gmail.com> <20161020143603.GC2733@stefanha-x1.localdomain>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Thu, 27 Oct 2016 03:05:35 +0200
Message-ID: <CALXu0UeW6Cssiij_+VW8afnHre3zwvBcg5OR=J7A2WKUv9fRWA@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] NFS: add AF_VSOCK support to NFS client
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 October 2016 at 16:36, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> On Sat, Oct 08, 2016 at 02:42:17AM +0200, Cedric Blancher wrote:
>> So basically you're creating a new (Red Hat) Linux-only wormhole which
>> bypasses all network security between VM host and guest and needs
>> extra work&thought&tool support (wireshark, valgrind, ...) to handle,
>> trace, debug, monitor and secure?
>
> vsock is not Linux-only and not Red Hat-only.

This is clearly Red Hat only. Debian and Ubuntu folks already have
rejected this out of security concerns, so why are you pressing this?
Where is support for other operating systems, like Windows, FreeBSD or
Solaris/Illumos?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
