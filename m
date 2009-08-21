From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Fri, 21 Aug 2009 21:09:33 +0200
Message-ID: <d4098e2f0908211209g183dfda2u5ec3b5369391721f@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:44135 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbZHUTJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 15:09:32 -0400
Received: by fxm17 with SMTP id 17so618975fxm.37
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 12:09:33 -0700 (PDT)
In-Reply-To: <d4098e2f0908211208j55dee16fy146ddb8de81d8722-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> from uname:
> Linux (Ubuntu) 2.6.24-24-generic #1 SMP Tue Jun 30 19:54:36 UTC 2009
> x86_64 GNU/Linux
>
> from mount:
> type nfs (ro,tcp,rsize=8192,wsize=8192,nfsvers=3,addr=192.168.XX.YY)

sorry, that was wrong - it should read:
(rw,tcp,rsize=8192,wsize=8192,nfsvers=3,addr=192.168.XX.YY)

Cheers,
Stefan
