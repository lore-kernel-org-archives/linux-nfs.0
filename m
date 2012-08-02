Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42001 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175Ab2HBVyb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 17:54:31 -0400
Received: by ghrr11 with SMTP id r11so28452ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 14:54:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343943192.26497.2.camel@lade.trondhjem.org>
References: <CAJ75kXZb2_MGOrxG6JRyGEKdHm+t_yUk755DpqTvpdyVZ4TFzg@mail.gmail.com>
 <1343687301.28035.11.camel@lade.trondhjem.org> <CAJ75kXb=GpKFkOQRiMqqpoH6+wEOP4sh5spS4Y8y-k__mbE6kA@mail.gmail.com>
 <CAJ75kXYqHpLXUqW3FkVsXu3=pybaBaTZ0AGfRG8ur8OcwGKX-w@mail.gmail.com> <1343943192.26497.2.camel@lade.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 2 Aug 2012 23:54:10 +0200
Message-ID: <CAJ75kXbmo4FQwpFVk2NC9y5+jXpaEvUVr_viiTRMtA6mn28oVA@mail.gmail.com>
Subject: Re: wait_for_key_construction oops
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thank you for your reply.

On Thu, Aug 2, 2012 at 11:33 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> Have you applied commit b1027439dff844675f6c0df97a1b1d190791a699 (NFS:
> Force the legacy idmapper to be single threaded)? That patch is Cc:
> stable [>=3.4], and so needs to be applied to your kernel.
> There is also a minor fix from Dan Carpenter in commit
> 5abc03cd919535c61b813f2319cb38326a41e810 (NFS: kmalloc() doesn't return
> an ERR_PTR()) that should be applied.

Yes I have these two patches applied. I got the same trace with a
3.4.7 kernel including these patches.

-- 
William
