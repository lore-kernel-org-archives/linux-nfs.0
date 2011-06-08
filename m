Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54933 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab1FHHPL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 03:15:11 -0400
Received: by vws1 with SMTP id 1so144924vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2011 00:15:11 -0700 (PDT)
In-Reply-To: <20110608021852.GA20998@merit.edu>
References: <cover.1307464381.git.rees@umich.edu>
	<09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
	<4DEED80A.4000102@panasas.com>
	<20110608021852.GA20998@merit.edu>
Date: Wed, 8 Jun 2011 15:15:10 +0800
Message-ID: <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
From: Peng Tao <bergwolf@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 6/8/11, Jim Rees <rees@umich.edu> wrote:
> Benny Halevy wrote:
>
>   NAK.
>   This affects all layout types.  In particular it is undesired
>   for write layouts that extend the file with the objects layout.
>   The server can extend the layout segments range
>   over what the client requested so why would the client
>   ask for artificially large layouts?
>
> This has actually been the subject of some debate over Thursday night
> beers.  The problem we're trying to solve is that the client is spending 98%
> of its time in layoutget.  This patch gives us something like a 10x
> speedup.  But many of us think it's not the right fix.  I suggest we discuss
> next week.
>
> But note that this patch doesn't change anything unless you set the sysctl.
there is a default value of 2M. maybe we can set it to page size by
default so other layout are not affected and block layout can let
users set it by hand if they care about performance. does this make
sense?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Thanks,
-Bergwolf
