From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/4]: Fix EAGAIN handling for the filelayout
Date: Mon, 14 Jun 2010 20:08:26 -0400
Message-ID: <4C16C47A.3080305@panasas.com>
References: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19747 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752856Ab0FOAIZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 20:08:25 -0400
In-Reply-To: <1276460322-13873-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 13, 2010, 16:18 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> These patches remove pnfs_call_done and all the routines associated with it.
> They were quite buggy for filelayout, and tended to crash the client anytime
> EAGAIN handling was invoked (in particular on short reads.)
> 
> The first patch just has filelayout avoid using them entirely. It should NOT
> be reverted in the post-submit.
> 
> The subsequent patches remove the unused code for pnfs-submit. It is
> expected they will be reverted in the post-submit.
> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Merged at pnfs-all-2.6.35-rc3-2010-06-14 pnfs-submit
patches 2/4 to 4/4 reverted in pnfs post submit.

Thanks!

Benny
