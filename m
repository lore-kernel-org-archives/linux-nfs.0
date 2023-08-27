Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDE04C83F10
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Aug 2023 07:58:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229556AbjH0H6U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Aug 2023 03:58:20 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36538 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230118AbjH0H5x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Aug 2023 03:57:53 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3B92D10A;
        Sun, 27 Aug 2023 00:57:50 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id C45F062022;
        Sun, 27 Aug 2023 07:57:49 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D483AC433C8;
        Sun, 27 Aug 2023 07:57:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1693123069;
        bh=P4lsFlifRgGl4it2BA7doRsmnOUDU03SRSFRthQgHW4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=rvVjaCPgR7djXjmsBKp+D/t4WmEwBdTztOsa2aaL4UTksn2utvyEGz0RIXVsMMm08
         LIGU0JUpMRTtNOTm+XJQCLHGx7l+OFzdi4eJ80EARniQInx4n4jaRL6Z/VbOyDVKA6
         +MxePoHqWO3MPX51UKAtL18en/Jj2fljYDZxnMHg=
Date:   Sun, 27 Aug 2023 09:57:34 +0200
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Harshit Mogalapalli <harshit.m.mogalapalli@oracle.com>
Cc:     brauner@kernel.org, chuck.lever@oracle.com, bfields@fieldses.org,
        stable@vger.kernel.org, linux-nfs@vger.kernel.org, hch@lst.de,
        jlayton@kernel.org, vegard.nossum@oracle.com,
        naresh.kamboju@linaro.org
Subject: Re: [PATCH 6.1.y 0/2] Address ltp nfs test failure.
Message-ID: <2023082729-angles-aids-741f@gregkh>
References: <20230825161603.371792-1-harshit.m.mogalapalli@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230825161603.371792-1-harshit.m.mogalapalli@oracle.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Aug 25, 2023 at 09:16:01AM -0700, Harshit Mogalapalli wrote:
> These two are backports for 6.1.y. Conflict resolution in done in
> both patches.
> 
> I have tested LTP-nfs fchown02 and chown02 on 6.1.y with below patches
> applied. The tests passed.
> 
> I would like to have a review as I am not familiar with this code.
> 
> Thanks to Vegard for helping me with this.
> 
> Thanks,
> Harshit
> 
> Christian Brauner (2):
>   nfs: use vfs setgid helper
>   nfsd: use vfs setgid helper
> 
>  fs/attr.c          | 1 +
>  fs/internal.h      | 2 --
>  fs/nfs/inode.c     | 4 +---
>  fs/nfsd/vfs.c      | 4 +++-
>  include/linux/fs.h | 2 ++
>  5 files changed, 7 insertions(+), 6 deletions(-)
> 
> -- 
> 2.34.1
> 

All now queued up, thanks.

greg k-h
