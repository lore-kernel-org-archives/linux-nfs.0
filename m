Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:36710 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab2JIHRW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 03:17:22 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2811209lag.19
        for <linux-nfs@vger.kernel.org>; Tue, 09 Oct 2012 00:17:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <mrjgxqrrinodrdsaqxus6fyb.1349647566180@email.android.com>
References: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
	<mrjgxqrrinodrdsaqxus6fyb.1349647566180@email.android.com>
Date: Tue, 9 Oct 2012 15:17:20 +0800
Message-ID: <CA+a=Yy7AbGQwOqoZDacdJy-RCL3MoHyGVE=jaqXwiccx1U-tbA@mail.gmail.com>
Subject: Re: [PATCH-Resend] NFS41: layoutget optimize and pnfsblock cleanup
From: Peng Tao <bergwolf@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/8/12, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
> Aren't these already in the nfs-for-next branch?
>
No. You only merged the IO alignment and bugfix patches.
These are layoutget size optimization that you and Boaz reviewed sometime ago.

Thanks,
Tao
