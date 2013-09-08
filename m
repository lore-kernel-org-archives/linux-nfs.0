Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:56640 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3IHOEn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 10:04:43 -0400
Received: by mail-ve0-f180.google.com with SMTP id jz11so2834937veb.11
        for <linux-nfs@vger.kernel.org>; Sun, 08 Sep 2013 07:04:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378648830.3165.2.camel@leira.trondhjem.org>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXZVrytD9J2yZ61tcEFC2bDoYE1pGUT+Wt4U8s_HJd2ODA@mail.gmail.com> <1378648830.3165.2.camel@leira.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Sun, 8 Sep 2013 16:04:21 +0200
Message-ID: <CAJ75kXadApKMJVCyTV9+=HZ_93AeOv5kOn6HmHArgsG-ocPSbA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Fix NFSv4 client-side security autonegotiation
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 8, 2013 at 4:00 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> I wasn't planning on doing that as it is easy to work around the problem
> by using an explicit 'sec=' option. That said, if the distros do want it
> in 3.10, then they should be able to sponsor its inclusion in the stable
> series.

ack, understood.

Regards,
-- 
William
