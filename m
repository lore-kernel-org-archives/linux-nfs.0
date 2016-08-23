Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hoggar.fisica.ufpr.br ([200.238.171.242]:56936 "EHLO
        hoggar.fisica.ufpr.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755474AbcHWWXs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 18:23:48 -0400
Date: Tue, 23 Aug 2016 19:23:12 -0300
From: Carlos Carvalho <carlos@fisica.ufpr.br>
To: linux-nfs@vger.kernel.org
Subject: Re: crashes in 4.6.5
Message-ID: <20160823222312.aweswujuqvphvy3o@fisica.ufpr.br>
References: <20160804203612.xqzevnqyzkfxwfv3@fisica.ufpr.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160804203612.xqzevnqyzkfxwfv3@fisica.ufpr.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're still stuck with this problem. We tried many versions since 4.1 to no
avail, the machine freezes in less than 48h. 4.7 didn't last 5min. Yesterday I
tried 4.7.2 on another machine, which only does nfsv3, and it froze in about 6h
with rcu_sched stalls; it runs 4.6.5 without problem. So it seems the problem
is worse in 4.7.

I cannot prove that the bug is in nfsd but the only machines that have problems
are those who do nfs exporting.

The crashing server is stable now for 13 days running Debian's kernel 3.16-0-4.
This means that hardware problems are extremely unlikely.

Is everybody else only running old kernels in nfs servers?
