From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/8]: pnfs_submit: removal of fsdata manipulation
Date: Thu, 06 May 2010 22:45:56 +0300
Message-ID: <4BE31C74.2090208@panasas.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49243 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756139Ab0EFTqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:46:04 -0400
Received: by wyg36 with SMTP id 36so286032wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 12:46:03 -0700 (PDT)
In-Reply-To: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 03, 2010, 4:00 +0300, Fred Isaman <iisaman@netapp.com> wrote:
> These revert patches in the submit branch in order to remove the fsdata manipulation needed by the block driver, followed immediately by the post-submit "un-reverts".
> 
> They apply on top of the 13 patches Andy previously sent.

patches 1-4 committed to pnfs-submit
5-8 to pnfs

Thanks!

Benny

> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

