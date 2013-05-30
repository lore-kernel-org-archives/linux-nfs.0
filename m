Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:42886 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968203Ab3E3LVS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 07:21:18 -0400
Received: by mail-wi0-f171.google.com with SMTP id hq7so4435289wib.4
        for <linux-nfs@vger.kernel.org>; Thu, 30 May 2013 04:21:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <674900017.56203.1369873870112.JavaMail.root@erie.cs.uoguelph.ca>
References: <BC47EE42-5F58-4555-A49C-4175B75943D8@oracle.com> <674900017.56203.1369873870112.JavaMail.root@erie.cs.uoguelph.ca>
From: Bram Vandoren <brambi@gmail.com>
Date: Thu, 30 May 2013 13:20:56 +0200
Message-ID: <CACQjR_Dr0T9H0DxzbDtQ=8FfLWK0yk_Gg8Xj02K54JyBWpyZ+g@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Rick,

> If you happen to have Cisco gear between the client and server, you might
> want to check for IDS enabled? (Don't ask me how you do that. I've never
> touched a Cisco switch. I also saw something suggestion that Juniper
> switches do something similar, but it didn't indicate how to disable the
> capability.)

We don't use an IDS. We use HP procurve switches.I doubt (hope) they
don't inject RSTs.

Thanks,
Bram.
