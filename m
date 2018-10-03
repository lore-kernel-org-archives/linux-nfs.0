Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vs1-f44.google.com ([209.85.217.44]:42676 "EHLO
        mail-vs1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726964AbeJDBzx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2018 21:55:53 -0400
Received: by mail-vs1-f44.google.com with SMTP id w16-v6so3891179vso.9
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2018 12:06:13 -0700 (PDT)
MIME-Version: 1.0
References: <CAN-5tyH_+OZJ+eUGvqvo+-EuG1OdaoFYERNKi=k=CDxpOFVoCQ@mail.gmail.com>
 <e2541b5d08b823aaec01195178e87ba39526aa92.camel@hammerspace.com>
In-Reply-To: <e2541b5d08b823aaec01195178e87ba39526aa92.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 3 Oct 2018 15:06:01 -0400
Message-ID: <CAN-5tyFVb_jqt+jknn2+o6_Cu=7cKw4qt9B_e2pd0azu2-7zaQ@mail.gmail.com>
Subject: Re: NFS/TCP timeouts
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 3, 2018 at 2:45 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Wed, 2018-10-03 at 14:31 -0400, Olga Kornievskaia wrote:
> > Hi folks,
> >
> > Is it true that NFS mount option "timeo" has nothing to do with the
> > socket's setting of the user-specified timeout TCP_USER_TIMEOUT.
> > Instead, when creating a TCP socket NFS uses either default/hard
> > coded
> > value of 60s for v3 or for v4.x it's lease based. Is there no value
> > is
> > having an adjustable TCP timeout value?
> >
>
> It is adjusted. Please see the calculation in
> xs_tcp_set_socket_timeouts().

but it's not user configurable, is it? I don't see a way to modify
v3's default 60s TCP timeout. and also in v4, the timeouts are set
from xs_tcp_set_connect_timeout() for the lease period but again not
user configurable, as far as i can tell.

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
