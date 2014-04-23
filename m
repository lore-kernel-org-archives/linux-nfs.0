Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35552 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaDWSBv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 14:01:51 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so1286874iec.11
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 11:01:50 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 23 Apr 2014 20:01:50 +0200
Message-ID: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
Subject: Tuning Linux NFSv4 for high latency connections?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Are there any options to improve the Linux NFSv4 performance over a
high latency connection?

We currently use Solaris/Illumos as NFSv4 server and client over a
cross continental Internet connection. Latency is terrible (~220ms)
but the counter this by running work in parallel so the latency is
mostly mitigated.

We now wish to migrate (short: Away from Oracle because support is
basically unbearable) to Linux (tested SuSE 13.1 and current Fedora)
and build times are 17 times (!!!) SLOWER than on Solaris/Illumos.

Are there any tunables besides actimeo=300?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
