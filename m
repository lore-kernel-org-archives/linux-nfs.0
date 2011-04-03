Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54674 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab1DCRCq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Apr 2011 13:02:46 -0400
Received: by yxs7 with SMTP id 7so1940614yxs.19
        for <linux-nfs@vger.kernel.org>; Sun, 03 Apr 2011 10:02:45 -0700 (PDT)
In-Reply-To: <20110403151229.GA13399@merit.edu>
References: <20110331165258.GA3048@merit.edu> <BANLkTinFftt0OiLYmY3cipXTtx1uTYoJPg@mail.gmail.com>
 <20110403151229.GA13399@merit.edu>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 4 Apr 2011 01:02:25 +0800
Message-ID: <BANLkTimV2zSJ59b+JJLg2itTg5zzYhs30A@mail.gmail.com>
Subject: Re: client hang in lock_flocks()
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Jim,

On Sun, Apr 3, 2011 at 11:12 PM, Jim Rees <rees@umich.edu> wrote:
> Peng Tao wrote:
>
>  Would you please send the complete trace log, or maybe open a bugzilla
>  entry and attach it there?
>
> Here is everything that was reported to me.  I can ask for rpc info and a
> tcpdump if that would be useful.
Yes, rpc info is helpful. Please do
'echo 0 > /proc/sys/sunrpc/rpc_debug'
when the hang happens and upload /var/log/messages.

And corresponding nfs.ko and sunrpc.ko would help analysis too.


-- 
Thanks,
-Bergwolf
