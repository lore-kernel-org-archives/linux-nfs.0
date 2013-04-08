Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:44056 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935617Ab3DHKQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2013 06:16:08 -0400
Received: by mail-vc0-f172.google.com with SMTP id gd11so1600060vcb.17
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2013 03:16:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1365280195.3651.4.camel@leira.trondhjem.org>
References: <1365196588-25403-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXY-Yt_DNrKz7VfQPudw-1DkcKaK5dr3Wz7KmByyxwMSCQ@mail.gmail.com> <1365280195.3651.4.camel@leira.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 8 Apr 2013 12:15:47 +0200
Message-ID: <CAJ75kXac4k07HMcbob2OmAhH4M+Dp1hmZbC+8uAZPB2AdrEbQw@mail.gmail.com>
Subject: Re: [PATCH 0/2] Stable patches for NFSv4/4.1 trunking
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 6, 2013 at 10:29 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> The main reason is that it should be a _very_ rare event, since it
> requires a call to try_to_get_module(THIS) to fail, and so I can't see
> that it could ever cause a huge leakage.
> If someone can show that it is more of a problem than I suggest above,
> then I'm happy to reconsider.

Understood. I didn't know a patch fixing a very rare event could not
go in stable.

--
William
