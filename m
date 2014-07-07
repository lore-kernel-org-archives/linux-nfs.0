Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:54221 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaGGQYm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 12:24:42 -0400
Received: by mail-ig0-f179.google.com with SMTP id uq10so4553054igb.6
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 09:24:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALXu0UeS=8tCj13a6O=W8wVr8Ke+CLpd6fUNqB35dYB2kj4hmw@mail.gmail.com>
References: <CALXu0UeS=8tCj13a6O=W8wVr8Ke+CLpd6fUNqB35dYB2kj4hmw@mail.gmail.com>
Date: Mon, 7 Jul 2014 18:24:41 +0200
Message-ID: <CALXu0Uf9XOoZk8LQPcktWr=i6SAe903O0eLQYiLTFNWx=vxY=g@mail.gmail.com>
Subject: Re: NFSv4 delegations criteria? Fwd: Tuning Linux NFSv4 for high
 latency connections?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anyone?

Ced

On 23 April 2014 23:03, Cedric Blancher <cedric.blancher@gmail.com> wrote:
> What are the criteria for grating a file delegation in NFSv4? Are file
> delegations retained even if a process closes a file and the next
> process in the chain opens it again (e.g. in a shell script)?
>
> Ced
>
> PS: Who again grants NFSv4 delegations? Server or client? Do
> delegations work when data are appended at the end of a file?
>
> ---------- Forwarded message ----------
> From: Cedric Blancher <cedric.blancher@gmail.com>
> Date: 23 April 2014 20:01
> Subject: Tuning Linux NFSv4 for high latency connections?
> To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
>
>
> Are there any options to improve the Linux NFSv4 performance over a
> high latency connection?
>
> We currently use Solaris/Illumos as NFSv4 server and client over a
> cross continental Internet connection. Latency is terrible (~220ms)
> but the counter this by running work in parallel so the latency is
> mostly mitigated.
>
> We now wish to migrate (short: Away from Oracle because support is
> basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
> and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.
>
> Are there any tunables besides actimeo=300?
>
> Ced
> --
> Cedric Blancher <cedric.blancher@gmail.com>
> Institute Pasteur
>
>
> --
> Cedric Blancher <cedric.blancher@gmail.com>
> Institute Pasteur



-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
