Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:47136 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab1HHOd3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 10:33:29 -0400
Received: by vxi9 with SMTP id 9so2488132vxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2011 07:33:28 -0700 (PDT)
In-Reply-To: <1312645934-4436-1-git-send-email-bergwolf@gmail.com>
References: <1312645934-4436-1-git-send-email-bergwolf@gmail.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 8 Aug 2011 22:33:08 +0800
Message-ID: <CA+a=Yy6XvDX_7v=91wzsWnRf1ZxDxQzewSh7OtaNw_J3dEUq3Q@mail.gmail.com>
Subject: Re: [PATCH-RFC 0/2] pNFS: recoalesce pages when ld read/write fails
To: linux-nfs@vger.kernel.org
Cc: rees@umich.edu, bhalevy@tonian.com, Trond.Myklebust@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 6, 2011 at 11:52 PM, Peng Tao <bergwolf@gmail.com> wrote:
> Hi,
>
> I start to look at the error handling for ld_read/write_done.
> The two patches try to address the error handling for read/write pagelist
> failures, via nfs readpage/writepage interface. Please see if this method
> is proper. Thanks!
FWIW, this is just what we need for recoalescing pages when IO fails.
Currently ld_read/write_done is called in default workqueue, which is
not really a good place for IO path code. Trond mentioned that nfsiod
is not an ideal place for it either. So do we need to create a pnfs
private workqueue for this? Any other suggestions?

-- 
Thanks,
-Bergwolf
