From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/4] pnfs-submit code removal patches
Date: Mon, 12 Jul 2010 18:46:57 +0300
Message-ID: <4C3B38F1.9050105@panasas.com>
References: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24371 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752328Ab0GLPq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 11:46:59 -0400
In-Reply-To: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 08, 2010, 22:25 +0300, Fred Isaman <iisaman@netapp.com> wrote:
> All these patches should be immediately reverted in the post-submit branch.
> 
> The first three take advantage of the fact that we are only using
> full-file layouts to remove some code.
> 
> The fourth is a repeat of a previously sent patch that seems to have
> fallen throught the the cracks.

Hmm, it looks like I had a pilot error on this one.
Will fix.

Benny

> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
