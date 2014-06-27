Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:47516 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaF0FsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jun 2014 01:48:22 -0400
Received: by mail-wi0-f179.google.com with SMTP id cc10so2151405wib.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 22:48:21 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 26 Jun 2014 22:48:20 -0700
Message-ID: <CA+FToV_mN=sdSb=Hzhb9uzXCJ4xHcE4brR+bWDZmC=fqx65_MA@mail.gmail.com>
Subject: Exponential backoff when polling by NFSv4 client causes poor throughput
From: Swagatika Prusty <itsswagatika@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Would it not be more appropriate to have the polling use an alternate
approach such as logarithmic due to the following reasons:

1) For a workload that exhibits contention for locks, the clients get
locks much after the lock becomes available.
2) Typical IO completes in 1-2s. Considering this, the polling interval
growing as 1,2,4,8,16,30 s seems sub-optimal.


Thanks,
Swagatika
