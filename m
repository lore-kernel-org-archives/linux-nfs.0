Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42641 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1AND7y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 22:59:54 -0500
In-Reply-To: <8482.1294926315@jrobl>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
	<8138.1294924927@jrobl>
	<676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com>
	<8482.1294926315@jrobl>
Date: Fri, 14 Jan 2011 14:59:53 +1100
Message-ID: <AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com>
Subject: Re: NFS root lockups with -next 20110113
From: Nick Piggin <npiggin@gmail.com>
To: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 14, 2011 at 12:45 AM, J. R. Okajima <hooanon05@yahoo.co.jp> wrote:
>
> Santosh Shilimkar:
>> It works. My board booted with NFS with below patch
>
> ----------------------------------------
>
> Mark Brown;
>> Seems to do the trick:
>>
>> Tested-by: Mark Brown <broonie@opensource.wolsfonmicro.com>
>
> Thank you so quick tests.
> When I post the patch to be mainlined, I will add Tested-by for both of
> you. But Nick Piggin may take another approach.

Thanks for your help, can you see how I've fixed it in my vfs-scale
tree? What do you think?

Thanks,
Nick
