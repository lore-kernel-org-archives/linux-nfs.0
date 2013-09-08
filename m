Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:60900 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab3IHN4K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 09:56:10 -0400
Received: by mail-vc0-f182.google.com with SMTP id hf12so3242995vcb.41
        for <linux-nfs@vger.kernel.org>; Sun, 08 Sep 2013 06:56:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Sun, 8 Sep 2013 15:55:49 +0200
Message-ID: <CAJ75kXZVrytD9J2yZ61tcEFC2bDoYE1pGUT+Wt4U8s_HJd2ODA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Fix NFSv4 client-side security autonegotiation
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Sun, Sep 8, 2013 at 1:18 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> So, it turns out that security autonegotition on the NFSv4 client has been
> broken since Linux 3.10. Nobody has noticed so far, and that is probably
> because it is broken on the Linux server too...

Since 3.10.x kernel will be a long term support, are these patches
going to be applied in stable tree?

Regards,

-- 
William
