From: Yudong Gao <stgyd@umich.edu>
Subject: Re: Write delegation
Date: Wed, 4 Aug 2010 12:21:30 -0700
Message-ID: <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35391 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739Ab0HDTVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 15:21:53 -0400
Received: by gyg10 with SMTP id 10so2121772gyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Aug 2010 12:21:52 -0700 (PDT)
In-Reply-To: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am not able to find the implementation of directory delegation,
either. Similarly, the callback functions CB_NOTIFY is not
implemented, either. I find that in preprocss_nfs41_op() in
callback_xdr.c, whenever a CB_NOTIFY is encountered, an
NFS4ERR_NOTSUPP is returned directly.

Am I missing something? Or they are just not supported in the current version?

Thanks a lot!

best,

Yudong

On Mon, Aug 2, 2010 at 5:17 PM, Yudong Gao <stgyd@umich.edu> wrote:
> Hi,
>
> I am looking at the delegation implementation in the source code of
> NFS 4.1 in kernel 2.6.32.15. I can find the code for read delegation,
> which is working and can serve the read requests locally. But I can
> never find the code about write delegation, which is supposed to cache
> the write update locally. I try to look at the functions including
> nfs_writepage(s), nfs_file_flush() but none of them checks or uses the
> write delegation.
>
> Is write delegation currently implemented in NFS 4.1?
>
> Thanks!
>
> best,
>
> Yudong
>
