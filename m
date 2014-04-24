Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:64012 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbaDXRWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 13:22:10 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so2693683iec.36
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 10:22:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424031216.GA18817@umich.edu>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
	<20140424031216.GA18817@umich.edu>
Date: Thu, 24 Apr 2014 19:22:10 +0200
Message-ID: <CALXu0UdsUk2bSWUzOXLHJ1FKtnZMyo0OHJSj=0hQpwwHVu52zw@mail.gmail.com>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Jim Rees <rees@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24 April 2014 05:12, Jim Rees <rees@umich.edu> wrote:
> Cedric Blancher wrote:
>
>   Are there any options to improve the Linux NFSv4 performance over a
>   high latency connection?
>
> We did some work along these lines at CITI years ago. As I remember, the
> main thing was to increase net.ipv4.tcp_[rw]mem on the server side, because
> tcp auto-tuning was being defeated. This may be less of an issue with your
> work load, which sounds like many small files rather than one big one.  In
> theory, NFSv4 delegations should help, but I don't know how well that works.

Trond, can you help?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
